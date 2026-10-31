#!/usr/bin/env python3
"""Runs the tests with Verilator and compares the observed lines of each test
with its expected output.

Usage:
    python3 tools/run_verilator.py [--verilator PATH] [--seed N] [--all] [-j N]
                                   [--build-jobs N] [--json FILE] [TEST ...]

With no TEST arguments, runs the tests whose `:oracle:` lists verilator@5.052;
with --all, every test that does not depend on x or z values
(`:fourstate: no`), as Verilator is a two-state simulator. Each test is built
with the pinned UVM library (see tools/uvm_common.py) by `verilator --binary
--timing`, and run with random initial values and the given seed, so a test
that depended on uninitialized values shows up as a difference. --build-jobs
is passed to Verilator as -j (0, the default, lets it use every hardware
thread for the C++ build of a model).

The model of a UVM test is large, so Verilator builds it with a precompiled
header, which records the absolute path of the build directory. ccache would
return such a header built in another directory and break the build, so the
runner removes OBJCACHE from the environment of the build.

Only the lines that begin with "UT: " are compared (README.md, "What is
observed"). The exit code and messages are checked against `:expected_exit:`
and `:expected_stderr_regex:`; a test with `:should_fail_because:` matches
when Verilator rejects it with an error at the place that
`:expected_stderr_regex:` names.

A test whose `:oracle:` does not list verilator@5.052 is reported as a known
difference when it does not match, and does not make the run fail. With
--json, the result of every test is also written to FILE in the form that
tools/suite_results.py describes. Exits with 1 if a test recorded with
Verilator does not match.
"""

import argparse
import concurrent.futures
import os
import subprocess
import sys
import tempfile
from pathlib import Path

import suite_results
import uvm_common

ROOT = Path(__file__).resolve().parent.parent
ORACLE = "verilator@5.052"
# Verilator stops the run at the first $error unless told to allow more; the
# standard has $error report the error and the run go on (1800-2023 20.10).
ERROR_LIMIT = 1000000


def selected(tests: list[Path], everything: bool) -> list[Path]:
    two_state = [t for t in tests if suite_results.header(t).get("fourstate") == "no"]
    if everything:
        return two_state
    return [t for t in two_state if ORACLE in suite_results.header(t).get("oracle", "").split()]


def run(test: Path, verilator: str, seed: int, build_jobs: int) -> tuple[bool, str]:
    problem = uvm_common.version_problem(test)
    if problem:
        return False, problem
    fields = suite_results.header(test)
    sources, include_dirs = suite_results.files(test)
    top = suite_results.top_module(test)
    with tempfile.TemporaryDirectory() as tmp:
        obj = Path(tmp) / "obj"
        b = subprocess.run(
            [verilator, "--binary", "--timing", "-j", str(build_jobs),
             "-Wno-fatal", "-Wno-lint", "-Wno-style",
             "--x-assign", "unique", "--x-initial", "unique",
             *[f"-I{d}" for d in [*uvm_common.include_dirs(), *include_dirs]],
             *[f"-D{d}" for d in [*uvm_common.defines(test), *suite_results.defines(test)]],
             *(["--top-module", top] if top else []), "-Mdir", str(obj), "--prefix", "Vt",
             *map(str, uvm_common.sources()), *map(str, sources), str(test)],
            capture_output=True, text=True, errors="replace",
            env={k: v for k, v in os.environ.items() if k != "OBJCACHE"})
        if "should_fail_because" in fields:
            return suite_results.judge_illegal(test, b.returncode == 0, b.stdout + b.stderr)
        if b.returncode != 0:
            err = [l for l in b.stderr.splitlines() if l.startswith("%Error")]
            compiler = [l for l in (b.stdout + b.stderr).splitlines() if ": error: " in l]
            return False, "build failed: " + (compiler[0] if compiler else err[0] if err else "")
        try:
            r = subprocess.run([str(obj / "Vt"), "+verilator+rand+reset+2",
                                f"+verilator+seed+{seed}", f"+verilator+error+limit+{ERROR_LIMIT}",
                                *suite_results.run_args(test)],
                               capture_output=True, text=True, errors="replace", cwd=tmp,
                               timeout=300)
        except subprocess.TimeoutExpired:
            return False, "timed out"
    want = suite_results.expected_output(test, "verilator")
    if want is None:
        return False, "no :expected_stdout:"
    got = uvm_common.observed(r.stdout)
    if got != want:
        return False, "output differs: " + suite_results.first_difference(got, want)
    why = suite_results.judge_run(test, r.returncode, r.stdout + r.stderr)
    return not why, why


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--verilator", default="verilator", help="verilator executable")
    ap.add_argument("--seed", type=int, default=1, help="seed for random initial values")
    ap.add_argument("--all", action="store_true",
                    help="run every two-state test, not only those recorded with Verilator")
    ap.add_argument("-j", "--jobs", type=int, default=1, help="number of tests run at once")
    ap.add_argument("--build-jobs", type=int, default=0,
                    help="parallel jobs of the C++ build of a model (0: every hardware thread)")
    ap.add_argument("--json", type=Path, default=None, help="also write the results to this file")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    tests = args.tests or selected(suite_results.find_tests(), args.all)
    failed = known = 0
    inputs = suite_results.fingerprints(tests) if args.json else None
    runner_hash = suite_results.runner_digest("verilator") if args.json else None
    statuses = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, args.verilator, args.seed, args.build_jobs), tests)
        for t, (ok, why) in zip(tests, results):
            name = suite_results.test_id(t)
            recorded = ORACLE in suite_results.header(t).get("oracle", "").split()
            if not recorded:
                known += 1
                if not ok:
                    print(f"KNOWN {name}: the expected output is not from Verilator 5.052",
                          flush=True)
            elif not ok:
                failed += 1
                print(f"FAIL {name}: {why}", flush=True)
            statuses[name] = ("pass" if ok else "fail" if recorded else "known", why)
    print(f"{len(tests) - known - failed}/{len(tests) - known} tests match"
          + (f"; {known} other tests not counted" if known else ""))
    if args.json:
        suite_results.write(args.json, "verilator", "Verilator",
                            suite_results.tool_version([args.verilator, "--version"]), statuses,
                            inputs=inputs, runner_sha256=runner_hash,
                            configuration={"seed": args.seed, "uvm": uvm_common.lock()["version"]})
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
