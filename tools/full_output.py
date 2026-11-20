#!/usr/bin/env python3
"""Saves the whole standard output of each test, and compares two sets of
saved outputs.

Usage:
    python3 tools/full_output.py capture --simulator verilator --output DIR
                                 [--seed N] [--all] [-j N] [--build-jobs N]
                                 [--verilator PATH] [TEST ...]
    python3 tools/full_output.py capture --simulator kirimasim --output DIR
                                 --kirimasim PATH [-j N] [TEST ...]
    python3 tools/full_output.py compare BASE OTHER [--json FILE]

The runners judge a test by its `UT: ` lines, which the standard determines.
The rest of the output, such as the form of a report, a printer's table or a
topology listing, is not determined by the standard, so the suite does not
judge it. With the same library and the same test, however, a difference in
that output between two simulators comes from the simulators. This tool keeps
that evidence apart from conformance: it changes no expectation, no oracle
and no verdict, and its results are not part of the runner records.

capture runs the tests through the simulator's own runner
(tools/run_verilator.py or tools/run_kirimasim.py), so the commands are the
runner's, and saves what each run prints on standard output. It does not
change the runner: it only keeps the output that the runner reads. With no
TEST arguments it takes the tests that the runner takes (for Verilator, those
recorded with verilator@5.052, or every two-state test with --all). Each
output goes to DIR/<test id>.txt after these normalizations, and
DIR/index.json lists the SHA-256 of each file with the simulator, its version,
the seed and the runner's fingerprint:

    - the repository's directory becomes <root>, and a temporary build
      directory becomes <tmp>
    - lines that the simulator itself prints about the run are dropped: for
      Verilator those that begin with "- " (the $finish line and the
      simulation report)

compare reads two such directories. For each test in both it says whether the
outputs are identical, and if not, where they first differ and whether the
`UT: ` lines differ too. A test in only one directory is listed as missing in
the other. Exits with 0 whatever the outputs are, and with 1 only when a
directory is not a capture. See docs/results.md, "Whole-output comparison",
and its Japanese counterpart.
"""

import argparse
from collections import Counter
import concurrent.futures
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import threading

import suite_results
import uvm_common

ROOT = Path(__file__).resolve().parent.parent
OBSERVED = "UT: "
TMP = re.compile(r"(?:/private)?(?:/var/folders|/tmp|/var/tmp)/[^\s:'\"]*")
DROP = {"verilator": re.compile(r"^- "), "kirimasim": None}


def normalize(text: str, simulator: str, root: Path = ROOT) -> str:
    """The output without what depends on the place and the run."""
    drop = DROP[simulator]
    lines = []
    for line in text.splitlines():
        if drop is not None and drop.match(line):
            continue
        line = line.replace(str(root), "<root>")
        lines.append(TMP.sub("<tmp>", line))
    return "".join(line + "\n" for line in lines)


def digest(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


class Recorder:
    """Wraps subprocess.run for one runner module and keeps the standard
    output of each simulation by the thread that asked for it."""

    def __init__(self, module, is_run):
        self.module = module
        self.is_run = is_run
        self.local = threading.local()
        self.real = module.subprocess.run

    def __enter__(self):
        def run(command, *args, **kwargs):
            result = self.real(command, *args, **kwargs)
            if self.is_run(command) and getattr(self.local, "outputs", None) is not None:
                self.local.outputs.append(result.stdout or "")
            return result
        self.module.subprocess = _Subprocess(self.module.subprocess, run)
        return self

    def __exit__(self, *_):
        self.module.subprocess = self.module.subprocess.original

    def collect(self, call):
        """Runs call() and returns its result with the outputs it produced."""
        self.local.outputs = []
        try:
            return call(), list(self.local.outputs)
        finally:
            self.local.outputs = None


class _Subprocess:
    """The subprocess module with run replaced, for one runner module only."""

    def __init__(self, original, run):
        self.original = original
        self.run = run

    def __getattr__(self, name):
        return getattr(self.original, name)


def write_capture(out: Path, simulator: str, version: str, seed, runner_sha: str,
                  outputs: dict, statuses: dict) -> None:
    out.mkdir(parents=True, exist_ok=True)
    files = {}
    for name, text in sorted(outputs.items()):
        path = out / (name + ".txt")
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        files[name] = {"sha256": digest(text), "lines": text.count("\n"),
                       "status": statuses.get(name)}
    index = {"kind": "full-output-capture", "simulator": simulator, "version": version,
             "seed": seed, "runner_sha256": runner_sha,
             "uvm": uvm_common.lock()["version"], "tests": files,
             "without_output": sorted(n for n in statuses if n not in outputs)}
    (out / "index.json").write_text(json.dumps(index, indent=1) + "\n", encoding="utf-8")


def capture_verilator(args) -> int:
    import run_verilator
    tests = args.tests or run_verilator.selected(suite_results.find_tests(), args.all)
    tests = [t for t in tests if "should_fail_because" not in suite_results.header(t)]
    declarations = run_verilator.load_declarations()
    outputs, statuses = {}, {}
    is_run = lambda command: str(command[0]).endswith("/Vt")   # noqa: E731
    with Recorder(run_verilator, is_run) as recorder:
        def one(test):
            (ok, why), got = recorder.collect(
                lambda: run_verilator.run(test, args.verilator, args.seed, args.build_jobs,
                                          declarations=declarations))
            return suite_results.test_id(test), ok, why, got
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
            for name, ok, why, got in pool.map(one, tests):
                statuses[name] = "match" if ok else why.split(":")[0]
                if got:
                    outputs[name] = normalize(got[0], "verilator")
    write_capture(args.output, "verilator",
                  suite_results.tool_version([args.verilator, "--version"]), args.seed,
                  suite_results.runner_digest("verilator"), outputs, statuses)
    print(f"{len(outputs)} outputs saved to {args.output}; {len(tests) - len(outputs)} tests "
          "gave none")
    return 0


def capture_kirimasim(args) -> int:
    import run_kirimasim
    exe = shutil.which(args.kirimasim)
    if exe is None:
        print(f"full_output: cannot find {args.kirimasim}", file=sys.stderr)
        return 1
    exe = str(Path(exe).resolve())
    tests = args.tests or suite_results.find_tests()
    tests = [t for t in tests if "should_fail_because" not in suite_results.header(t)]
    declarations = run_kirimasim.load_declarations()
    one_unit = run_kirimasim.single_unit_tests()
    outputs, statuses = {}, {}
    is_run = lambda command: str(command[0]) == exe   # noqa: E731
    with Recorder(run_kirimasim, is_run) as recorder:
        def one(test):
            name = suite_results.test_id(test)
            (status, _), got = recorder.collect(
                lambda: run_kirimasim.run(test, exe, declarations, name in one_unit))
            return name, status, got
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
            for name, status, got in pool.map(one, tests):
                statuses[name] = status
                # A test that the simulator could not run has no output to compare.
                if got and status in ("pass", "fail") and got[0].strip():
                    outputs[name] = normalize(got[0], "kirimasim")
    write_capture(args.output, "kirimasim", suite_results.tool_version([exe, "--version"]),
                  None, suite_results.runner_digest("kirimasim"), outputs, statuses)
    print(f"{len(outputs)} outputs saved to {args.output}; {len(tests) - len(outputs)} tests "
          "gave none")
    return 0


def load_capture(directory: Path) -> dict:
    index = directory / "index.json"
    if not index.is_file():
        raise ValueError(f"{directory}: not a capture (no index.json)")
    data = json.loads(index.read_text(encoding="utf-8"))
    if data.get("kind") != "full-output-capture":
        raise ValueError(f"{directory}: not a capture")
    return data


def observed(text: str) -> list[str]:
    return [line for line in text.splitlines() if line.startswith(OBSERVED)]


def first_difference(a: str, b: str) -> dict:
    """The first line at which two outputs differ."""
    la, lb = a.splitlines(), b.splitlines()
    for number, (x, y) in enumerate(zip(la, lb), 1):
        if x != y:
            return {"line": number, "base": x[:200], "other": y[:200]}
    number = min(len(la), len(lb)) + 1
    longer = la if len(la) > len(lb) else lb
    return {"line": number, "base": la[number - 1][:200] if longer is la else None,
            "other": lb[number - 1][:200] if longer is lb else None}


def compare(base_dir: Path, other_dir: Path) -> dict:
    base, other = load_capture(base_dir), load_capture(other_dir)
    names = sorted(set(base["tests"]) | set(other["tests"]))
    tests, counts = {}, Counter()
    for name in names:
        in_base, in_other = name in base["tests"], name in other["tests"]
        if not (in_base and in_other):
            kind = "missing in other" if in_base else "missing in base"
            tests[name] = {"result": kind}
        elif base["tests"][name]["sha256"] == other["tests"][name]["sha256"]:
            kind = "identical"
            tests[name] = {"result": kind}
        else:
            a = (base_dir / (name + ".txt")).read_text(encoding="utf-8")
            b = (other_dir / (name + ".txt")).read_text(encoding="utf-8")
            same_observed = observed(a) == observed(b)
            kind = "differs outside UT lines" if same_observed else "differs in UT lines"
            tests[name] = {"result": kind, "first": first_difference(a, b)}
        counts[kind] += 1
    return {"base": {k: base[k] for k in ("simulator", "version", "seed", "uvm")},
            "other": {k: other[k] for k in ("simulator", "version", "seed", "uvm")},
            "counts": dict(sorted(counts.items())), "tests": tests}


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)
    cap = commands.add_parser("capture")
    cap.add_argument("--simulator", choices=("verilator", "kirimasim"), required=True)
    cap.add_argument("--output", type=Path, required=True)
    cap.add_argument("--seed", type=int, default=1)
    cap.add_argument("--all", action="store_true")
    cap.add_argument("-j", "--jobs", type=int, default=1)
    cap.add_argument("--build-jobs", type=int, default=0)
    cap.add_argument("--verilator", default="verilator")
    cap.add_argument("--kirimasim", default="kirimasim")
    cap.add_argument("tests", nargs="*", type=Path)
    cmp_ = commands.add_parser("compare")
    cmp_.add_argument("base", type=Path)
    cmp_.add_argument("other", type=Path)
    cmp_.add_argument("--json", type=Path)
    args = parser.parse_args(argv)
    if args.command == "capture":
        args.tests = [t.resolve() for t in args.tests]
        return capture_verilator(args) if args.simulator == "verilator" else capture_kirimasim(args)
    try:
        result = compare(args.base, args.other)
    except ValueError as error:
        print(f"full_output: {error}", file=sys.stderr)
        return 1
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=1, ensure_ascii=False) + "\n",
                             encoding="utf-8")
    for name, entry in result["tests"].items():
        if entry["result"] not in ("identical",):
            where = f" (line {entry['first']['line']})" if "first" in entry else ""
            print(f"{entry['result']}: {name}{where}")
    print(", ".join(f"{count} {kind}" for kind, count in result["counts"].items())
          or "no test in either capture")
    return 0


if __name__ == "__main__":
    sys.exit(main())
