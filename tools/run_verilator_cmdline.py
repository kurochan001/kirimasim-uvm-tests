#!/usr/bin/env python3
"""Run the explicit command-line subset with an original VPI argument bridge.

This separate condition (verilator_cmdline) supplies actual process arguments
with pinned UVM regex DPI and disabled HDL DPI. Every fixture must opt in and fingerprint
the original argument bridge through :dpi_c:. Ordinary and HDL runners are unchanged.
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

SIMULATOR = "verilator_cmdline"
ORACLE = "verilator@5.052"
BACKEND = (Path(__file__).parent / "cmdline_backend" / "uvm_cmdline_vpi.cpp").resolve()
REGEX = BACKEND.with_name("uvm_cmdline_regex.cpp")
COMPAT = BACKEND.with_name("malloc.h")
# Verilator stops the run at the first $error unless told to allow more; the
# standard has $error report the error and the run go on (1800-2023 20.10).
ERROR_LIMIT = 1000000


def selected(tests: list[Path], all_tests: bool = False) -> list[Path]:
    return [t for t in tests
            if suite_results.header(t).get("uvm_cmdline_backend") == "vpi"
            and (all_tests or suite_results.header(t).get("uvm_cmdline_oracle") == ORACLE)]


def backend_problem(test: Path) -> str:
    fields = suite_results.header(test)
    if fields.get("uvm_cmdline_backend") != "vpi" or fields.get("uvm_dpi") != "yes":
        return "test must explicitly request the VPI command-line backend and UVM DPI"
    if fields.get("fourstate") != "no":
        return "this runner records two-state command-line fixtures only"
    source = (test.parent / fields.get("dpi_c", "").removeprefix("@")).resolve()
    if source != BACKEND or not source.is_file():
        return "test must declare the original backend through :dpi_c:"
    defines = set(uvm_common.defines(test) + suite_results.defines(test))
    if "UVM_HDL_NO_DPI" not in defines:
        return "disable unrelated HDL DPI in fixture metadata"
    declared = {(test.parent / name).resolve() for name in fields.get("files", "").split()}
    if not {REGEX, COMPAT} <= declared:
        return "declare the pinned-regex wrapper and portable header through :files:"
    if any(d.split("=")[0] in {"UVM_NO_DPI", "UVM_CMDLINE_NO_DPI", "UVM_REGEX_NO_DPI"}
           for d in defines):
        return "backend requires enabled command-line and regex DPI"
    return ""


def run(test: Path, verilator: str, seed: int, build_jobs: int, *,
        seeds: tuple[int, ...] | None = None) -> tuple[bool, str]:
    problem = backend_problem(test) or uvm_common.version_problem(test)
    if problem:
        return False, problem
    fields = suite_results.header(test)
    sources, include_dirs = suite_results.files(test)
    top = suite_results.top_module(test)
    with tempfile.TemporaryDirectory() as tmp:
        obj = Path(tmp) / "obj"
        b = subprocess.run(
            [verilator, "--binary", "--timing", "--vpi",
             "-CFLAGS", f"-I{BACKEND.parent}", "-j", str(build_jobs),
             "-Wno-fatal", "-Wno-lint", "-Wno-style",
             "--x-assign", "unique", "--x-initial", "unique",
             *[f"-I{d}" for d in [*uvm_common.include_dirs(), *include_dirs]],
             *[f"-D{d}" for d in [*uvm_common.defines(test), *suite_results.defines(test)]],
             *(["--top-module", top] if top else []), "-Mdir", str(obj), "--prefix", "Vt",
             *map(str, uvm_common.sources()), *map(str, sources), str(test), str(BACKEND), str(REGEX)],
            capture_output=True, text=True, errors="replace",
            env={k: v for k, v in os.environ.items() if k != "OBJCACHE"})
        if "should_fail_because" in fields:
            return suite_results.judge_illegal(test, b.returncode == 0, b.stdout + b.stderr)
        if b.returncode != 0:
            err = [l for l in b.stderr.splitlines() if l.startswith("%Error")]
            compiler = [l for l in (b.stdout + b.stderr).splitlines() if ": error: " in l]
            return False, "build failed: " + (compiler[0] if compiler else err[0] if err else "")
        want = suite_results.expected_output(test, "verilator")
        if want is None:
            return False, "no :expected_stdout:"
        for current_seed in seeds if seeds is not None else (seed,):
            try:
                r = subprocess.run([str(obj / "Vt"), "+verilator+rand+reset+2",
                                    f"+verilator+seed+{current_seed}",
                                    f"+verilator+error+limit+{ERROR_LIMIT}",
                                    *suite_results.run_args(test)],
                                   capture_output=True, text=True, errors="replace", cwd=tmp,
                                   timeout=300)
            except subprocess.TimeoutExpired:
                return False, f"seed {current_seed}: timed out"
            if r.returncode < 0:
                return False, f"seed {current_seed}: crashed (signal {-r.returncode})"
            got = uvm_common.observed(r.stdout)
            if got != want:
                return False, f"seed {current_seed}: output differs: " + (
                    suite_results.first_difference(got, want))
            if "expected_exit" not in fields and r.returncode != 0:
                return False, f"seed {current_seed}: unexpected nonzero exit code"
            why = suite_results.judge_run(test, r.returncode, r.stdout + r.stderr)
            if why:
                return False, f"seed {current_seed}: {why}"
    return True, ""


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--verilator", default="verilator")
    ap.add_argument("--seeds", type=int, nargs="+", default=[1, 73])
    ap.add_argument("-j", "--jobs", type=int, default=1)
    ap.add_argument("--build-jobs", type=int, default=2)
    ap.add_argument("--json", type=Path)
    ap.add_argument("--all", action="store_true", help="include untagged spec-only cases")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()
    if args.jobs < 1 or args.build_jobs < 0:
        ap.error("--jobs must be positive and --build-jobs must be nonnegative")
    version = suite_results.tool_version([args.verilator, "--version"])
    if not version.startswith("Verilator 5.052 "):
        ap.error("this evidence condition requires Verilator 5.052")
    tests = args.tests or selected(suite_results.find_tests(), args.all)
    if not tests:
        ap.error("no command-line fixtures selected")
    inputs = suite_results.fingerprints(tests)
    runner_hash = suite_results.runner_digest(SIMULATOR)
    statuses = {}
    configuration = {"seeds": args.seeds, "uvm": uvm_common.lock()["version"],
                     "uvm_cmdline_backend": "original-vpi-process-arguments",
                     "regex_dpi": "pinned-uvm-2020.3.1", "hdl_dpi": False}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = {pool.submit(run, t, args.verilator, args.seeds[0], args.build_jobs,
                               seeds=tuple(args.seeds)): t for t in tests}
        for future in concurrent.futures.as_completed(futures):
            test = futures[future]
            ok, why = future.result()
            name = suite_results.test_id(test)
            recorded = suite_results.header(test).get("uvm_cmdline_oracle") == ORACLE
            statuses[name] = ("pass" if ok else "fail" if recorded else "known", why)
            print(f"{statuses[name][0].upper()} {name}" + (f": {why}" if why else ""),
                  flush=True)
            if args.json:
                suite_results.write(args.json, SIMULATOR, "Verilator / VPI command line", version,
                                    statuses, inputs={n: inputs[n] for n in statuses},
                                    runner_sha256=runner_hash, configuration=configuration)
    failed = sum(s == "fail" for s, _ in statuses.values())
    passed = sum(s == "pass" for s, _ in statuses.values())
    known = sum(s == "known" for s, _ in statuses.values())
    print(f"{passed}/{len(tests)} command-line fixtures match; {known} known")
    return int(failed != 0)


if __name__ == "__main__":
    sys.exit(main())
