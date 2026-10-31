#!/usr/bin/env python3
"""Run UVM tests with an unreleased simulator under the public alias Ghost.

The private JSON profile supplies arguments (a list), environment (a mapping)
and uvm_mode (pinned or bundled). Bundled mode also declares uvm_library_dir
or uvm_embedded: true. Pinned mode compiles the locked package;
bundled mode leaves loading UVM to the profile and the simulator. Results
explicitly distinguish these modes: a bundled run is not evidence for the
locked library. Profiles, versions, paths and diagnostics stay private.
"""

import argparse
import concurrent.futures
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import suite_results
import uvm_common

ANSI = re.compile(r"\x1b\[[0-9;]*m")


def parse_profile(data: bytes) -> dict:
    profile = json.loads(data)
    if not isinstance(profile, dict) or profile.get("uvm_mode") not in ("pinned", "bundled"):
        raise ValueError("invalid UVM mode")
    arguments, environment = profile.get("arguments"), profile.get("environment")
    if not isinstance(arguments, list) or not all(isinstance(a, str) for a in arguments):
        raise ValueError("invalid arguments")
    if not isinstance(environment, dict) or not all(
            isinstance(k, str) and isinstance(v, str) for k, v in environment.items()):
        raise ValueError("invalid environment")
    if profile["uvm_mode"] == "bundled":
        directory = profile.get("uvm_library_dir")
        embedded = profile.get("uvm_embedded", False)
        if not isinstance(embedded, bool) or (directory is not None and
                                             (not isinstance(directory, str) or not directory)):
            raise ValueError("invalid bundled library identity")
        if (directory is not None) == embedded:
            raise ValueError("declare a library directory or an embedded library")
    elif "uvm_library_dir" in profile or "uvm_embedded" in profile:
        raise ValueError("pinned mode uses the locked library")
    return profile


def library_state(profile: dict) -> dict:
    """Hash the library tree using the lock's canonical path/content format.

    Paths stay private. A truly embedded library is covered by the executable
    fingerprint instead. Directory-backed bundled libraries need their own
    fingerprint even when the executable is unchanged.
    """
    pinned = profile["uvm_mode"] == "pinned"
    if not pinned and profile.get("uvm_embedded") is True:
        return {"uvm_library": "embedded"}
    directory = uvm_common.library_dir() if pinned else Path(profile["uvm_library_dir"])
    if not directory.is_dir() or not any((directory / name).is_file()
                                         for name in ("uvm_pkg.sv", "src/uvm_pkg.sv")):
        raise ValueError("cannot identify the library tree")
    paths = sorted(path for path in directory.rglob("*") if path.is_file())
    digest = hashlib.sha256()
    for path in paths:
        digest.update(path.relative_to(directory).as_posix().encode() + b"\0")
        digest.update(hashlib.sha256(path.read_bytes()).digest())
    value = digest.hexdigest()
    if pinned and (value != uvm_common.lock()["content_sha256"]
                   or len(paths) != uvm_common.lock()["files"]):
        raise ValueError("the library differs from the lock")
    return {"uvm_library": "pinned" if pinned else "directory",
            "uvm_content_sha256": value, "uvm_files": len(paths)}


def run(test: Path, simulator: str, profile: dict) -> tuple[str, str]:
    fields = suite_results.header(test)
    if fields.get("uvm") != uvm_common.lock()["version"]:
        return "fail", "the test does not name the locked UVM release"
    pinned = profile["uvm_mode"] == "pinned"
    if pinned:
        problem = uvm_common.version_problem(test)
        if problem:
            return "fail", problem
    sources, includes = suite_results.files(test)
    if pinned:
        sources = [*uvm_common.sources(), *sources]
        includes = [*uvm_common.include_dirs(), *includes]
    top = suite_results.top_module(test)
    with tempfile.TemporaryDirectory() as tmp:
        try:
            result = subprocess.run(
                [simulator, *profile["arguments"],
                 *[f"+incdir+{d}" for d in includes],
                 *[f"+define+{d}" for d in [*uvm_common.defines(test),
                                            *suite_results.defines(test)]],
                 *(["-top", top] if top else []), *map(str, sources),
                 str(test.resolve()), *suite_results.run_args(test)],
                capture_output=True, text=True, errors="replace", cwd=tmp,
                env={**os.environ, **profile["environment"]}, timeout=300)
        except subprocess.TimeoutExpired:
            return "fail", "timed out"
        except (OSError, ValueError):
            return "fail", "could not start the simulator"
    if result.returncode < 0:
        return "fail", f"crashed (signal {-result.returncode})"
    messages = ANSI.sub("", result.stdout + result.stderr)
    if "should_fail_because" in fields:
        ok, why = suite_results.judge_illegal(test, result.returncode == 0, messages)
        return ("pass" if ok else "fail"), why.split("; the first is:", 1)[0]
    want = suite_results.expected_output(test)
    if want is None:
        return "fail", "no :expected_stdout:"
    if uvm_common.observed(ANSI.sub("", result.stdout)) != want:
        return "fail", "output differs"
    # A complete observation followed by an error must not silently pass.
    if "expected_exit" not in fields and result.returncode != 0:
        return "fail", "unexpected nonzero exit code"
    why = suite_results.judge_run(test, result.returncode, messages)
    return ("fail" if why else "pass"), why


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--simulator", required=True, help="private simulator executable")
    ap.add_argument("--profile", required=True, type=Path, help="private JSON profile")
    ap.add_argument("-j", "--jobs", type=int, default=1)
    ap.add_argument("--json", type=Path)
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()
    if args.jobs < 1:
        ap.error("--jobs must be at least 1")
    exe = shutil.which(args.simulator)
    if exe is None:
        ap.error("cannot find the private simulator executable")
    exe = str(Path(exe).resolve())
    try:
        profile_bytes = args.profile.read_bytes()
        profile = parse_profile(profile_bytes)
        binary_hash = hashlib.sha256(Path(exe).read_bytes()).hexdigest()
        library = library_state(profile)
    except (OSError, ValueError, TypeError):
        ap.error("cannot read the private executable/profile or verify the UVM library")
    profile_hash = hashlib.sha256(profile_bytes).hexdigest()
    tests = args.tests or suite_results.find_tests()
    inputs = suite_results.fingerprints(tests) if args.json else None
    runner_hash = suite_results.runner_digest("ghost") if args.json else None
    failed, statuses = 0, {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, exe, profile), tests)
        for test, (status, why) in zip(tests, results):
            if status == "fail":
                failed += 1
                print(f"FAIL {suite_results.test_id(test)}: {why}", flush=True)
            statuses[suite_results.test_id(test)] = (status, why)
    print(f"{len(tests) - failed}/{len(tests)} tests match", flush=True)
    if args.json:
        try:
            changed = (hashlib.sha256(Path(exe).read_bytes()).hexdigest() != binary_hash
                       or hashlib.sha256(args.profile.read_bytes()).hexdigest() != profile_hash
                       or library_state(profile) != library)
        except (OSError, ValueError):
            changed = True
        if changed:
            print("Private executable, profile or UVM library changed; results discarded.",
                  file=sys.stderr)
            return 2
        pinned = profile["uvm_mode"] == "pinned"
        configuration = {"test_uvm": uvm_common.lock()["version"],
                         "uvm_source": profile["uvm_mode"], "uvm_pinned": pinned,
                         "binary_sha256": binary_hash, "profile_sha256": profile_hash,
                         **library}
        suite_results.write(args.json, "ghost", "Ghost", f"private build {binary_hash[:12]}",
                            statuses, inputs=inputs, runner_sha256=runner_hash,
                            configuration=configuration)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
