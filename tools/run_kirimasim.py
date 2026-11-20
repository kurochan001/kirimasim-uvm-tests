#!/usr/bin/env python3
"""Runs the tests with kirimasim and compares the observed lines of each test
with its expected output.

Usage:
    python3 tools/run_kirimasim.py [--kirimasim PATH] [-j N] [--json FILE] [TEST ...]

With no TEST arguments, runs every test. Each test runs in its own temporary
directory as `kirimasim --timescale=1ns/1ps +incdir+<uvm>/src +define+...
<uvm>/src/uvm_pkg.sv <sources> <test>.sv <args>`, with the pinned UVM library
and its macros (see tools/uvm_common.py). The default time scale is the one
that tools/run_verilator.py passes: the library's package declares no time
unit, and 1800-2023 3.14.2.3 makes it an error when only some design elements
specify one. Only the lines that begin with "UT: " are compared
(docs/testing.md, "What is observed").

A test with `:uvm_dpi: yes` is not run and is reported as unsupported: it
needs the library's DPI-C and VPI code, and this runner passes no DPI back
end, so a run would not show what kirimasim itself supports.

A test that uses a construct kirimasim does not support yet, which it reports
with exit code 2 and an "error: unsupported:" message, is reported as
unsupported. A test with `:should_fail_because:` matches when kirimasim
rejects it (exit code 2) with an error at the place `:expected_stderr_regex:`
names. The exit code and standard error are checked against `:expected_exit:`
and `:expected_stderr_regex:` (see tools/suite_results.py); without
`:expected_exit:`, the run must end with exit code 0, as in
tools/run_verilator.py.

A default-server line that begins with `UVM_ERROR ` or `UVM_FATAL ` fails the
test unless coverage/uvm_reports.json declares that severity for it. The
declarations file is not an input fingerprint; its SHA-256 is recorded in the
result configuration.

With --json, the result of every test is also written to FILE in the form
that tools/suite_results.py describes. Exits with 1 if a test does not match
or is unsupported.
"""

import argparse
import concurrent.futures
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import suite_results
import uvm_common

UNSUPPORTED = re.compile(r"error: unsupported: (.*)")
TIMESCALE = "1ns/1ps"
NO_DPI = "this runner passes no DPI back end"
DECLARATIONS = suite_results.ROOT / "coverage" / "uvm_reports.json"
REPORT = re.compile(r"^(UVM_ERROR|UVM_FATAL)(?! :) ")


def load_declarations() -> dict:
    """The tests that may print a default-server error or fatal, or {}."""
    if not DECLARATIONS.is_file():
        return {}
    return json.loads(DECLARATIONS.read_text(encoding="utf-8")).get("tests", {})


def declarations_digest() -> str:
    """The evidence link for the declarations, which are not an input."""
    return (hashlib.sha256(DECLARATIONS.read_bytes()).hexdigest()
            if DECLARATIONS.is_file() else "missing")


def undeclared_report(test: Path, output: str, declarations: dict) -> str:
    """Why an output prints a severity the test does not declare, or ""."""
    try:
        entry = declarations.get(suite_results.test_id(test), {})
    except ValueError:
        entry = {}
    for severity, key in (("UVM_ERROR", "error"), ("UVM_FATAL", "fatal")):
        if entry.get(key):
            continue
        line = next((l for l in output.splitlines()
                     if l.startswith(severity + " ") and REPORT.match(l)), None)
        if line:
            match = re.match(r"^(UVM_ERROR|UVM_FATAL).*?\[([^\]]*)\]\s*(.*)$", line)
            text = (f"{match.group(1)} [{match.group(2)}] {match.group(3)}"
                    if match else line[:160])
            return f"undeclared {severity}: {text}"
    return ""


def run(test: Path, kirimasim: str, declarations: dict | None = None) -> tuple[str, str]:
    """The status of the test (pass, fail or unsupported) and the reason."""
    problem = uvm_common.version_problem(test)
    if problem:
        return "fail", problem
    fields = suite_results.header(test)
    if fields.get("uvm_dpi") == "yes":
        return "unsupported", NO_DPI
    sources, include_dirs = suite_results.files(test)
    top = suite_results.top_module(test)
    with tempfile.TemporaryDirectory() as tmp:
        try:
            r = subprocess.run(
                [kirimasim, f"--timescale={TIMESCALE}",
                 *[f"+incdir+{d}" for d in [*uvm_common.include_dirs(), *include_dirs]],
                 *[f"+define+{d}" for d in [*uvm_common.defines(test), *suite_results.defines(test)]],
                 *([f"--top={top}"] if top else []), *map(str, uvm_common.sources()),
                 *map(str, sources), str(test.resolve()), *suite_results.run_args(test)],
                capture_output=True, text=True, errors="replace", cwd=tmp, timeout=300)
        except subprocess.TimeoutExpired:
            return "fail", "timed out"
    unsupported = UNSUPPORTED.search(r.stderr)
    if r.returncode == 2 and unsupported:
        return "unsupported", unsupported.group(1).strip()
    if "should_fail_because" in fields:
        # kirimasim rejects a design with exit code 2.
        if r.returncode not in (0, 2):
            return "fail", f"exit code {r.returncode}, expected 2"
        ok, why = suite_results.judge_illegal(test, r.returncode == 0, r.stderr)
        return ("pass" if ok else "fail"), why
    if r.returncode < 0:
        return "fail", f"crashed (signal {-r.returncode})"
    want = suite_results.expected_output(test, "kirimasim")
    if want is None:
        return "fail", "no :expected_stdout:"
    got = uvm_common.observed(r.stdout)
    if got != want:
        err = [l for l in r.stderr.splitlines() if ": error: " in l or ": fatal: " in l]
        return "fail", "output differs" + (f" (exit {r.returncode})" if r.returncode else "") + (
            f": {err[0].split(': ', 1)[-1]}" if err else ": " + suite_results.first_difference(got, want))
    if "expected_exit" not in fields and r.returncode != 0:
        return "fail", "unexpected nonzero exit code"
    why = suite_results.judge_run(test, r.returncode, r.stderr)
    if not why:
        why = undeclared_report(test, r.stdout, declarations or {})
    return ("fail" if why else "pass"), why


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--kirimasim", default="kirimasim", help="kirimasim executable")
    ap.add_argument("-j", "--jobs", type=int, default=1, help="number of tests run at once")
    ap.add_argument("--json", type=Path, default=None, help="also write the results to this file")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    exe = shutil.which(args.kirimasim)
    if exe is None:
        ap.error(f"cannot find {args.kirimasim}")
    exe = str(Path(exe).resolve())   # the tests run in other directories

    tests = args.tests or suite_results.find_tests()
    declarations = load_declarations()
    declarations_sha = declarations_digest()
    inputs = suite_results.fingerprints(tests) if args.json else None
    runner_hash = suite_results.runner_digest("kirimasim") if args.json else None
    failed = unsupported = 0
    statuses = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, exe, declarations), tests)
        for t, (status, why) in zip(tests, results):
            name = suite_results.test_id(t)
            if status == "unsupported":
                unsupported += 1
                print(f"UNSUPPORTED {name}: {why}", flush=True)
            elif status == "fail":
                failed += 1
                print(f"FAIL {name}: {why}", flush=True)
            statuses[name] = (status, why)
    print(f"{len(tests) - failed - unsupported}/{len(tests)} tests match"
          + (f"; {unsupported} use what kirimasim does not support yet" if unsupported else ""))
    if args.json:
        suite_results.write(args.json, "kirimasim", "kirimasim",
                            suite_results.tool_version([exe, "--version"]), statuses,
                            inputs=inputs, runner_sha256=runner_hash,
                            configuration={"uvm": uvm_common.lock()["version"],
                                           "uvm_reports": declarations_sha})
    return 1 if failed or unsupported else 0


if __name__ == "__main__":
    sys.exit(main())
