#!/usr/bin/env python3
"""Elaborates every test with slang and checks the result against
coverage/slang_frontend.json, the record of the tests for which slang reports
an error although the suite keeps them.

Usage:
    python3 tools/slang_elaborate.py check [-j N] [--json FILE] [TEST ...]
    python3 tools/slang_elaborate.py summary [--lang en|ja]

slang is the front end that kirimasim uses unmodified, and it is stricter than
Verilator, so this check finds a test that kirimasim could not elaborate
before the test is published. It needs the Python package pyslang (MIT
license) in the version that the record names; nothing else in the repository
needs it. Each test is elaborated in its own process with the files, include
directories, macros and top module that the runners use (tools/uvm_common.py
and tools/suite_results.py) and with the options of the record, which include
the default time scale that the runners pass.

The record lists only the tests that may differ from "a legal test has no
error, and an illegal design has an error that matches its
`:expected_stderr_regex:`". Each entry has one reason:

    library           the test follows the standard where the pinned library
                      differs, so it does not compile with that library; its
                      entry in coverage/known_causes.json has a library or
                      interpretation cause. "verilator_kind" says when
                      Verilator builds the test and differs only at run time
    warning-as-error  slang raises a warning to an error by default, for code
                      that the cited clause of 1800-2023 allows
    suspected-limit   slang rejects code that the cited clause of 1800-2023
                      appears to allow; kept as written and not reported
                      upstream without the user's decision
    single-unit       the test needs every file in one compilation unit
                      (1800-2023 3.12.1); it has no error with --single-unit
    accepted-illegal  slang accepts an illegal design, because the pinned
                      library differs from the standard there

check fails when a test outside the record has an error, when a listed test
no longer has its error, when the first error of a listed test changes, when
an illegal design is rejected without a line that matches its pattern, and
when an entry does not fit its test or the cause record. With TEST arguments
it checks only those tests. summary counts the entries by reason. See
docs/testing.md, "slang elaboration", and its Japanese counterpart.
"""

import argparse
from collections import Counter
import concurrent.futures
import json
import os
from pathlib import Path
import re
import subprocess
import sys

import suite_results
import uvm_common

ROOT = Path(__file__).resolve().parent.parent
RECORD = Path("coverage") / "slang_frontend.json"
CAUSES = Path("coverage") / "known_causes.json"
SIMULATOR = "verilator@5.054"
LANGUAGES = {"en", "ja"}
REASONS = ("library", "warning-as-error", "suspected-limit", "single-unit", "accepted-illegal")
LIBRARY_CAUSES = ("library", "interpretation")
# An error with its place, or one that slang prints without a place (for
# example a top-level module that does not exist), which also keeps the design
# from being elaborated.
ERROR = re.compile(r"^(?:(.*?):(\d+):(\d+): )?error: (.*)$", re.MULTILINE)
CLAUSE = re.compile(r"[0-9A-Z]+(\.[0-9]+)*")
# The child process: elaborate one command line and print the diagnostics.
ONE = """
import sys, pyslang
d = pyslang.driver.Driver()
d.addStandardArgs()
if not (d.parseCommandLine(" ".join(["slang"] + sys.argv[1:])) and d.processOptions()
        and d.parseAllSources()):
    sys.exit(2)
d.reportCompilation(d.createCompilation(), True)
"""


class FrontendError(ValueError):
    """The record does not match the tests or its own rules."""


def require(condition, message):
    if not condition:
        raise FrontendError(message)


def keys(value, required, where, optional=()):
    require(isinstance(value, dict), f"{where}: expected an object")
    present = set(value)
    missing = set(required) - present
    extra = present - set(required) - set(optional)
    require(not missing and not extra,
            f"{where}: expected fields {', '.join(sorted(required))}"
            + (f" (optional {', '.join(sorted(optional))})" if optional else ""))


def bilingual(value, where):
    keys(value, LANGUAGES, where)
    require(all(isinstance(text, str) and text.strip() for text in value.values()),
            f"{where}: both en and ja text are required")


def load(root=None):
    path = (root or ROOT) / RECORD
    require(path.is_file(), f"{RECORD}: missing")
    return json.loads(path.read_text(encoding="utf-8"))


def tests_by_id(root):
    return {suite_results.test_id(path): path for path in suite_results.find_tests(root)}


def known_causes(root):
    path = root / CAUSES
    if not path.is_file():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    return {entry["test"]: entry for entry in data["causes"]}


def validate(data, root=None):
    """Raises FrontendError unless the record fits the current tests."""
    root = root or ROOT
    keys(data, {"schema_version", "tool", "version", "options", "purpose", "tests"}, "record")
    require(data["schema_version"] == 1, "record: schema_version must be 1")
    require(data["tool"] == "pyslang", "record: tool must be pyslang")
    require(isinstance(data["version"], str) and re.fullmatch(r"\d+\.\d+\.\d+", data["version"]),
            "record: version must be an exact pyslang version")
    require(isinstance(data["options"], list)
            and all(isinstance(o, str) and o.startswith("--") for o in data["options"]),
            "record: options must be a list of slang options")
    bilingual(data["purpose"], "purpose")
    require(isinstance(data["tests"], dict), "tests: expected an object")
    require(list(data["tests"]) == sorted(data["tests"]), "tests: must be sorted by test id")
    current = tests_by_id(root)
    causes = known_causes(root)
    for name, entry in data["tests"].items():
        where = f"tests.{name}"
        require(name in current, f"{where}: no such test")
        keys(entry, {"reason", "error", "note"}, where, ("clauses_1800_2023", "verilator_kind"))
        reason = entry["reason"]
        require(reason in REASONS, f"{where}: reason must be one of {', '.join(REASONS)}")
        bilingual(entry["note"], f"{where}.note")
        fields = suite_results.header(current[name])
        illegal = "should_fail_because" in fields
        tagged = SIMULATOR in fields.get("oracle", "").split()
        require((reason == "accepted-illegal") == illegal,
                f"{where}: only an illegal design can be accepted-illegal, and it has no other "
                "reason")
        require((entry["error"] is None) == (reason == "accepted-illegal"),
                f"{where}: error is the first error message, or null for accepted-illegal")
        require(entry["error"] is None or (isinstance(entry["error"], str) and entry["error"]),
                f"{where}: error must be a message")
        cause = causes.get(name)
        if reason in ("library", "accepted-illegal"):
            require(not tagged and cause is not None and cause["cause"] in LIBRARY_CAUSES,
                    f"{where}: needs a library or interpretation entry in {CAUSES}")
        else:
            clauses = entry.get("clauses_1800_2023")
            require(isinstance(clauses, list) and clauses
                    and all(isinstance(c, str) and CLAUSE.fullmatch(c) for c in clauses),
                    f"{where}: clauses_1800_2023 must name the clauses that allow the code")
        if reason == "library":
            kind = cause["kind"]
            require(entry.get("verilator_kind") == (None if kind == "build" else kind),
                    f"{where}: verilator_kind must be {kind}" if kind != "build"
                    else f"{where}: Verilator also fails to build; no verilator_kind")
        else:
            require("verilator_kind" not in entry, f"{where}: verilator_kind is for reason library")
    return data


def command(test, options):
    """The slang arguments of a test: what the runners give their simulator."""
    fields = suite_results.header(test)
    sources, include_dirs = suite_results.files(test)
    top = suite_results.top_module(test)
    return [*options,
            *[f"-I{d}" for d in [*uvm_common.include_dirs(), *include_dirs]],
            *[f"-D{d}" for d in [*uvm_common.defines(test), *suite_results.defines(test)]],
            *(["--top", top] if top else []),
            *map(str, uvm_common.sources()), *map(str, sources), str(test.resolve())]


def elaborate(test, options):
    """The diagnostics that slang prints for a test."""
    try:
        r = subprocess.run([sys.executable, "-c", ONE, *command(test, options)],
                           capture_output=True, text=True, errors="replace", timeout=600)
    except subprocess.TimeoutExpired as error:
        raise FrontendError(f"{suite_results.test_id(test)}: slang timed out "
                            f"after {error.timeout:g} seconds") from None
    output = r.stdout + r.stderr
    require(r.returncode == 0 or (r.returncode == 2 and ERROR.search(output)),
            f"{suite_results.test_id(test)}: slang did not run: {output.strip()[-300:]}")
    return output


def errors(output):
    """The error messages of an output, without their places."""
    return [m.group(4) for m in ERROR.finditer(output)]


def error_lines(output):
    return "\n".join(m.group(0) for m in ERROR.finditer(output))


def judge(name, test, entry, output, single_unit_output=None):
    """Why a test's slang result is not what the record says, or ""."""
    fields = suite_results.header(test)
    found = errors(output)
    if "should_fail_because" in fields:
        if entry is not None:
            return "" if not found else "slang now rejects the design; remove its entry"
        if not found:
            return "slang accepts the illegal design, and the record has no entry"
        ok, why = suite_results.judge_illegal(test, False, error_lines(output))
        return "" if ok else why
    if entry is None:
        return f"slang reports an error: {found[0]}" if found else ""
    if not found:
        return "slang reports no error now; remove its entry"
    if found[0] != entry["error"]:
        return f"the first error is now: {found[0]}"
    if entry["reason"] == "single-unit" and errors(single_unit_output or ""):
        return ("an error remains with --single-unit: "
                + errors(single_unit_output)[0])
    return ""


def installed_version():
    try:
        import pyslang
    except ImportError:
        return None
    return pyslang.__version__


def check(data, tests, jobs, root=None):
    """The problems of the given tests, and the first error of each."""
    root = root or ROOT
    current = tests_by_id(root)
    names = sorted(suite_results.test_id(t) for t in tests) if tests else sorted(current)
    options = data["options"]

    def one(name):
        test = current[name]
        entry = data["tests"].get(name)
        output = elaborate(test, options)
        single = (elaborate(test, [*options, "--single-unit"])
                  if entry is not None and entry["reason"] == "single-unit" else None)
        found = errors(output)
        return name, judge(name, test, entry, output, single), (found[0] if found else None)

    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as pool:
        results = list(pool.map(one, names))
    return ([f"{name}: {why}" for name, why, _ in results if why],
            {name: first for name, _, first in results})


def summary(data):
    return {"version": data["version"], "options": data["options"],
            "entries": len(data["tests"]),
            "by_reason": dict(Counter(e["reason"] for e in data["tests"].values())),
            "verilator_builds_but_slang_rejects": sorted(
                n for n, e in data["tests"].items() if e.get("verilator_kind"))}


def single_unit_tests(root=None):
    """The tests that a runner must compile as one compilation unit."""
    path = (root or ROOT) / RECORD
    if not path.is_file():
        return set()
    data = json.loads(path.read_text(encoding="utf-8"))
    return {name for name, entry in data.get("tests", {}).items()
            if entry.get("reason") == "single-unit"}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=("check", "summary"))
    parser.add_argument("-j", "--jobs", type=int, default=os.cpu_count() or 1)
    parser.add_argument("--json", type=Path, help="write the first error of each test (check)")
    parser.add_argument("--lang", choices=("en", "ja"), default="en")
    parser.add_argument("tests", nargs="*", type=Path)
    args = parser.parse_intermixed_args(argv)
    try:
        data = validate(load())
        if args.command == "summary":
            s = summary(data)
            counts = ", ".join(f"{r} {s['by_reason'].get(r, 0)}" for r in REASONS)
            print(f"pyslang {s['version']} with {' '.join(s['options'])}: "
                  f"{s['entries']} entries ({counts})" if args.lang == "en" else
                  f"pyslang {s['version']}、option {' '.join(s['options'])}："
                  f"記録{s['entries']}件（{counts}）")
            return 0
        have = installed_version()
        require(have is not None,
                f"pyslang is not installed; run: python3 -m pip install pyslang=={data['version']}")
        require(have == data["version"],
                f"pyslang {have} is installed, but the record is for {data['version']}")
        problems, first = check(data, [t.resolve() for t in args.tests], max(1, args.jobs))
    except FrontendError as error:
        print(f"slang_elaborate: {error}", file=sys.stderr)
        return 1
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(first, indent=1, ensure_ascii=False) + "\n",
                             encoding="utf-8")
    for problem in problems:
        print(problem)
    print(f"{len(first)} tests elaborated with pyslang {data['version']}: "
          f"{len(problems)} problems; {len(data['tests'])} recorded entries")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
