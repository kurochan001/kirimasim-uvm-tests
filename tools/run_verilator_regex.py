#!/usr/bin/env python3
"""Rerun listed ordinary fixtures with the pinned UVM regex DPI enabled.

This separate condition (verilator_regex) rebuilds two-state fixtures that the
ordinary runner builds with UVM_NO_DPI, using the DPI condition of the
command-line subset: the library's regular-expression DPI and the original VPI
argument bridge, with HDL DPI disabled. Name matching through uvm_is_match then
uses the regular-expression DPI instead of the SystemVerilog glob fallback, and
command-line arguments such as +UVM_TESTNAME reach the library through its
command-line DPI. The fixtures and their expected output are unchanged;
coverage/regex_dpi_variants.txt selects them, and a selected line that carries
verilator@5.052 records a check that matched in this condition. Ordinary, HDL
and command-line runners are unchanged.
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

SIMULATOR = "verilator_regex"
ORACLE = "verilator@5.052"
LIST = suite_results.ROOT / "coverage" / "regex_dpi_variants.txt"
BACKEND_DIR = (Path(__file__).parent / "cmdline_backend").resolve()
BACKEND = BACKEND_DIR / "uvm_cmdline_vpi.cpp"
REGEX = BACKEND_DIR / "uvm_cmdline_regex.cpp"
# Verilator stops the run at the first $error unless told to allow more; the
# standard has $error report the error and the run go on (1800-2023 20.10).
ERROR_LIMIT = 1000000


def variants(path: Path = LIST) -> dict[str, bool]:
    """Test id to whether the line records a matching check, in listed order."""
    entries: dict[str, bool] = {}
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        words = line.split("#", 1)[0].split()
        if not words:
            continue
        if len(words) > 2 or (len(words) == 2 and words[1] != ORACLE):
            raise ValueError(f"{path.name}:{number}: expected '<test id> [{ORACLE}]'")
        if words[0] in entries:
            raise ValueError(f"{path.name}:{number}: {words[0]} is listed twice")
        entries[words[0]] = len(words) == 2
    return entries


def variant_problem(test: Path) -> str:
    """Why a fixture cannot be rebuilt in this condition, or "" if it can."""
    fields = suite_results.header(test)
    if fields.get("fourstate") != "no":
        return "this runner records two-state fixtures only"
    if fields.get("uvm_dpi") == "yes":
        return "the fixture already selects its own DPI condition"
    if "UVM_NO_DPI" not in uvm_common.defines(test):
        return "the ordinary build of this fixture does not use UVM_NO_DPI"
    if "should_fail_because" in fields:
        return "illegal-design fixtures are outside this condition"
    return ""


def defines(test: Path) -> list[str]:
    """The ordinary defines with UVM_NO_DPI narrowed to its HDL part."""
    kept = [d for d in uvm_common.defines(test) if d != "UVM_NO_DPI"]
    return ["UVM_HDL_NO_DPI", *kept, *suite_results.defines(test)]


def run(test: Path, verilator: str, seed: int, build_jobs: int, *,
        seeds: tuple[int, ...] | None = None) -> tuple[bool, str]:
    problem = variant_problem(test) or uvm_common.version_problem(test)
    if problem:
        return False, problem
    fields = suite_results.header(test)
    sources, include_dirs = suite_results.files(test)
    top = suite_results.top_module(test)
    with tempfile.TemporaryDirectory() as tmp:
        obj = Path(tmp) / "obj"
        b = subprocess.run(
            [verilator, "--binary", "--timing", "--vpi", "-CFLAGS", f"-I{BACKEND_DIR}",
             "-j", str(build_jobs), "-Wno-fatal", "-Wno-lint", "-Wno-style",
             "--x-assign", "unique", "--x-initial", "unique",
             *[f"-I{d}" for d in [*uvm_common.include_dirs(), *include_dirs]],
             *[f"-D{d}" for d in defines(test)],
             *(["--top-module", top] if top else []), "-Mdir", str(obj), "--prefix", "Vt",
             *map(str, uvm_common.sources()), *map(str, sources), str(test), str(BACKEND), str(REGEX)],
            capture_output=True, text=True, errors="replace",
            env={k: v for k, v in os.environ.items() if k != "OBJCACHE"})
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
    ap.add_argument("--all", action="store_true", help="include listed lines without a tag")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()
    if args.jobs < 1 or args.build_jobs < 0:
        ap.error("--jobs must be positive and --build-jobs must be nonnegative")
    version = suite_results.tool_version([args.verilator, "--version"])
    if not version.startswith("Verilator 5.052 "):
        ap.error("this evidence condition requires Verilator 5.052")
    listed = variants()
    if args.tests:
        tests = [t.resolve() for t in args.tests]
        unknown = [suite_results.test_id(t) for t in tests if suite_results.test_id(t) not in listed]
        if unknown:
            ap.error("not listed in coverage/regex_dpi_variants.txt: " + ", ".join(unknown))
    else:
        tests = [suite_results.ROOT / "tests" / (name + ".sv") for name, tagged in listed.items()
                 if tagged or args.all]
    if not tests:
        ap.error("no regex-DPI variants selected")
    inputs = suite_results.fingerprints(tests)
    runner_hash = suite_results.runner_digest(SIMULATOR)
    statuses = {}
    configuration = {"seeds": args.seeds, "uvm": uvm_common.lock()["version"],
                     "regex_dpi": "pinned-uvm-2020.3.1", "hdl_dpi": False,
                     "uvm_cmdline_backend": "original-vpi-process-arguments"}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = {pool.submit(run, t, args.verilator, args.seeds[0], args.build_jobs,
                               seeds=tuple(args.seeds)): t for t in tests}
        for future in concurrent.futures.as_completed(futures):
            test = futures[future]
            ok, why = future.result()
            name = suite_results.test_id(test)
            statuses[name] = ("pass" if ok else "fail" if listed[name] else "known", why)
            print(f"{statuses[name][0].upper()} {name}" + (f": {why}" if why else ""),
                  flush=True)
            if args.json:
                suite_results.write(args.json, SIMULATOR, "Verilator / pinned regex DPI",
                                    version, statuses,
                                    inputs={n: inputs[n] for n in statuses},
                                    runner_sha256=runner_hash, configuration=configuration)
    failed = sum(s == "fail" for s, _ in statuses.values())
    passed = sum(s == "pass" for s, _ in statuses.values())
    known = sum(s == "known" for s, _ in statuses.values())
    print(f"{passed}/{len(tests)} regex-DPI variants match; {known} known")
    return int(failed != 0)


if __name__ == "__main__":
    sys.exit(main())
