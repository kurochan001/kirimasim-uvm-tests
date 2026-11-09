#!/usr/bin/env python3
"""Selects the tagged Verilator checks that a CI job runs.

Usage:
    python3 tools/ci_select.py --base REV --output FILE [--limit N]
    python3 tools/ci_select.py --shard INDEX/COUNT [--directories DIRS] --output FILE
    python3 tools/ci_select.py --plan [--directories DIRS] --output FILE

The tagged checks are those that tools/run_verilator.py runs by default (the
`:oracle:` lists verilator@5.052). FILE receives one test path per line.

--base selects, for the quick Check workflow, the tagged checks whose recorded
inputs (suite_results.input_files: the design, declared helpers, literal
includes and every referenced expectation) differ between REV and HEAD, plus a
fixed canary. When REV is unavailable, when a file that affects every result
changed (the runner, its normalization, the library lock or fetcher), or when
more than N checks are affected, only the canary is selected and a warning
says that the full Regression workflow is required. A quick pass therefore
never stands in for the full selection.

--shard writes one disjoint, deterministic partition of the whole selection
for the Regression workflow; the shards of a COUNT together cover it exactly.

--directories (names under tests/, such as "u17 uG") narrows a Regression run
to the tagged checks that collect a file from one of those directories: their
own tests and every test elsewhere that uses one of their helpers. --plan
appends, for the Regression workflow, key=value lines to FILE (normally
$GITHUB_OUTPUT): the shard indices as a JSON list and their count (20 for the
whole selection, otherwise one shard for every SHARD_SIZE checks, at most 20),
and whether the command-line and regex-DPI jobs run, with the fixtures they
take when the run is narrowed (empty for their whole lists).

This file is not part of the runner fingerprint (suite_results.runner_digest),
so changing it does not invalidate stored execution evidence.
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path

import run_verilator
import suite_results

ROOT = suite_results.ROOT
CANARY = ("tests/u09/test_common_phases_run_in_order.sv",)
# Every result depends on these, so only the full selection checks a change.
GLOBAL = ("tools/run_verilator.py", "tools/suite_results.py", "tools/uvm_common.py",
          "tools/fetch_uvm.py", "third_party/uvm.lock")
LIMIT = 30
SHARDS = 20
SHARD_SIZE = 115


def tagged() -> list[Path]:
    return sorted(run_verilator.selected(suite_results.find_tests(), False))


def changed_paths(base: str) -> set[str] | None:
    """Repository paths that differ between base and HEAD, or None if unknown."""
    if not base or set(base) == {"0"}:
        return None
    try:
        out = subprocess.run(["git", "diff", "--name-only", "--no-renames", base, "HEAD", "--"],
                             cwd=ROOT, check=True, capture_output=True, text=True).stdout
    except (OSError, subprocess.CalledProcessError):
        return None
    return {line for line in out.splitlines() if line}


def relative(path: Path) -> str | None:
    try:
        return path.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return None


def affected(tests: list[Path], changed: set[str]) -> list[Path]:
    """The tests that have at least one changed recorded input."""
    return [t for t in tests
            if any(relative(p) in changed for p in suite_results.input_files(t))]


def plan(tests: list[Path], changed: set[str] | None,
         limit: int = LIMIT) -> tuple[list[Path], str | None]:
    """The tests to run and, when the selection is reduced to the canary, why."""
    canary = [ROOT / name for name in CANARY]
    if changed is None:
        return canary, "the base revision is unavailable"
    hit = sorted(changed.intersection(GLOBAL))
    if hit:
        return canary, "files that affect every result changed: " + ", ".join(hit)
    chosen = affected(tests, changed)
    if len(chosen) > limit:
        return canary, f"{len(chosen)} tagged checks are affected, more than {limit}"
    return sorted({t.resolve() for t in canary + chosen}), None


def in_directories(tests: list[Path], directories: list[str]) -> list[Path]:
    """The tests that collect a file from one of the named directories under tests/."""
    roots = []
    for name in directories:
        root = (ROOT / "tests" / name).resolve()
        if "/" in name or not root.is_dir():
            raise ValueError(f"no test directory {name!r}")
        roots.append(root)
    return [t for t in tests
            if any(p.resolve().is_relative_to(r) for p in suite_results.input_files(t) for r in roots)]


def shard_count(selected: int, narrowed: bool) -> int:
    if not narrowed:
        return SHARDS
    return min(SHARDS, -(-selected // SHARD_SIZE))


def regression_plan(directories: list[str]) -> dict[str, str]:
    """The GitHub outputs that shape one Regression run."""
    import run_verilator_cmdline
    import run_verilator_regex
    narrowed = bool(directories)
    tests = tagged()
    cmdline = run_verilator_cmdline.selected(suite_results.find_tests())
    regex = [ROOT / "tests" / (name + ".sv")
             for name, is_tagged in run_verilator_regex.variants().items() if is_tagged]
    if narrowed:
        tests, cmdline, regex = (in_directories(group, directories)
                                 for group in (tests, cmdline, regex))
    count = shard_count(len(tests), narrowed)
    return {"shards": "[" + ",".join(str(i) for i in range(count)) + "]", "count": str(count),
            "checks": str(len(tests)),
            "cmdline": "true" if cmdline else "false",
            "cmdline_tests": " ".join(relative(t) for t in cmdline) if narrowed else "",
            "regex": "true" if regex else "false",
            "regex_tests": " ".join(relative(t) for t in regex) if narrowed else ""}


def shard(tests: list[Path], index: int, count: int) -> list[Path]:
    if not 0 <= index < count:
        raise ValueError(f"shard {index}/{count} is out of range")
    selected = tests[index::count]
    if not selected:
        raise ValueError(f"shard {index}/{count} is empty")
    return selected


def summary(text: str) -> None:
    print(text)
    name = os.environ.get("GITHUB_STEP_SUMMARY")
    if name:
        with open(name, "a", encoding="utf-8") as f:
            f.write(text + "\n")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--base", help="select the checks whose inputs changed since this revision")
    mode.add_argument("--shard", help="select partition INDEX of COUNT, written INDEX/COUNT")
    mode.add_argument("--plan", action="store_true", help="append the Regression plan to FILE")
    ap.add_argument("--directories", default="",
                    help="narrow --shard or --plan to tests that use these directories")
    ap.add_argument("--limit", type=int, default=LIMIT,
                    help=f"most affected checks run before falling back (default {LIMIT})")
    ap.add_argument("--output", type=Path, required=True, help="file that receives the paths")
    args = ap.parse_args()
    directories = args.directories.split()
    if directories and args.base is not None:
        ap.error("--directories is for --shard or --plan")
    if args.plan:
        try:
            outputs = regression_plan(directories)
        except ValueError as e:
            ap.error(str(e))
        args.output.parent.mkdir(parents=True, exist_ok=True)
        with args.output.open("a", encoding="utf-8") as f:
            f.write("".join(f"{k}={v}\n" for k, v in outputs.items()))
        summary(f"Regression plan for {' '.join(directories) or 'every directory'}: "
                f"{outputs['checks']} tagged checks in {outputs['count']} shards; command-line "
                f"job {outputs['cmdline']}, regex-DPI job {outputs['regex']}")
        return 0
    tests = tagged()
    if args.shard is not None:
        try:
            if directories:
                tests = in_directories(tests, directories)
            index, count = (int(n) for n in args.shard.split("/"))
            selected = shard(tests, index, count)
        except ValueError as e:
            ap.error(str(e))
        summary(f"Shard {index}/{count}: {len(selected)} of {len(tests)} tagged checks"
                + (f" that use {' '.join(directories)}" if directories else ""))
    else:
        selected, reason = plan(tests, changed_paths(args.base), args.limit)
        if reason:
            print(f"::warning::Only the canary runs ({reason}); "
                  "run the Regression workflow for the full selection.")
        summary(f"Changed inputs since {args.base or '(none)'}: {len(selected)} of "
                f"{len(tests)} tagged checks selected"
                + (f"; canary only, because {reason}" if reason else ""))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("".join(f"{relative(t) or t}\n" for t in selected), encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
