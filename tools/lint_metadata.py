#!/usr/bin/env python3
"""Checks the metadata and the form of every test (README.md, "Test format").

Usage:
    python3 tools/lint_metadata.py [TEST ...]

Reports, for each test:

    field        a required field is missing, or a value is not allowed
    name         :name: is not the file name
    lrm          :lrm: does not start with 1800.2-2020, or names a clause that
                 tools/clauses_1800_2.txt does not list
    directory    the test is not in tests/u<chapter>/ of its first clause
    tags         :tags: does not hold u<chapter> and uvm
    uvm          :uvm: is not the version of third_party/uvm.lock
    oracle       :oracle: does not hold spec, or holds an unknown token
    expected     the expected output is missing, or a line of it does not
                 begin with "UT: "
    illegal      an illegal design has no :expected_stderr_regex:, or has an
                 expected output
    width        a comment line is longer than 80 columns, or code than 100
    verilator    a comment line starts with the word Verilator, which Verilator
                 reads as a directive
Exits with 1 if any test has a problem.
"""

import json
import re
import sys
from pathlib import Path

import suite_results

ROOT = Path(__file__).resolve().parent.parent
CLAUSES = {line.strip() for line in (ROOT / "tools" / "clauses_1800_2.txt").read_text().splitlines()
           if line.strip() and not line.startswith("#")}
STANDARDS = {"1800.2-2020", "1800-2023"}
REQUIRED = ("name", "description", "tags", "type", "lrm", "uvm", "oracle", "spec_check",
            "fourstate", "nondeterministic")
CHOICES = {"type": {"simulation", "elaboration"}, "spec_check": {"ai", "human"},
           "fourstate": {"yes", "no"}, "nondeterministic": {"yes", "no"},
           "uvm_dpi": {"yes", "no"}}
ORACLES = {"spec", "verilator@5.052"}


def chapter_dir(clause: str) -> str:
    head = clause.split(".")[0]
    return f"u{int(head):02d}" if head.isdigit() else f"u{head}"


def problems(test: Path, version: str) -> list[str]:
    fields = suite_results.header(test)
    found = []
    for name in REQUIRED:
        if not fields.get(name):
            found.append(f"field: no :{name}:")
    for name, allowed in CHOICES.items():
        if name in fields and fields[name] not in allowed:
            found.append(f"field: :{name}: {fields[name]} is not one of {sorted(allowed)}")
    if fields.get("name") and fields["name"] != test.stem:
        found.append("name: :name: is not the file name")
    lrm = fields.get("lrm", "").split()
    if not lrm or lrm[0] != "1800.2-2020":
        found.append("lrm: :lrm: does not start with 1800.2-2020")
    else:
        standard, first = None, None
        for token in lrm:
            if token in STANDARDS:
                standard = token
            elif standard == "1800.2-2020" and token not in CLAUSES:
                found.append(f"lrm: {token} is not a clause of 1800.2-2020")
            elif first is None and standard == "1800.2-2020":
                first = token
        if first is None:
            found.append("lrm: no clause of 1800.2-2020")
        else:
            want = chapter_dir(first)
            if test.parent.name != want:
                found.append(f"directory: the first clause {first} belongs in tests/{want}/")
            tags = fields.get("tags", "").split()
            if want not in tags or "uvm" not in tags:
                found.append(f"tags: :tags: should hold {want} and uvm")
    if fields.get("uvm") and fields["uvm"] != version:
        found.append(f"uvm: :uvm: {fields['uvm']} is not the locked {version}")
    oracle = fields.get("oracle", "").split()
    if oracle and ("spec" not in oracle or not set(oracle) <= ORACLES):
        found.append(f"oracle: :oracle: should hold spec and only {sorted(ORACLES)}")
    if "should_fail_because" in fields:
        if "expected_stderr_regex" not in fields:
            found.append("illegal: no :expected_stderr_regex:")
        if any(n.startswith("expected_stdout") for n in fields):
            found.append("illegal: an illegal design has no expected output")
    else:
        want = suite_results.expected_output(test)
        if want is None:
            found.append("expected: no :expected_stdout:")
        elif not want.strip():
            found.append("expected: the expected output is empty")
        else:
            bad = [n for n, l in enumerate(want.splitlines(), 1) if not l.startswith("UT: ")]
            if bad:
                found.append(f"expected: line {bad[0]} does not begin with 'UT: '")
    in_header = True
    for n, line in enumerate(test.read_text(encoding="utf-8").splitlines(), 1):
        if in_header:
            in_header = "*/" not in line
            continue
        text = line.strip()
        if text.startswith("//"):
            if len(line) > 80:
                found.append(f"width: line {n}: comment of {len(line)} columns")
            if re.match(r"//\s*verilator\b", text, re.IGNORECASE):
                found.append(f"verilator: line {n}")
        elif len(line) > 100:
            found.append(f"width: line {n}: code of {len(line)} columns")
    return found


def main() -> int:
    version = json.loads((ROOT / "third_party" / "uvm.lock").read_text())["version"]
    tests = [Path(a).resolve() for a in sys.argv[1:]] or suite_results.find_tests()
    bad = 0
    for test in tests:
        for problem in problems(test, version):
            bad += 1
            print(f"{suite_results.test_id(test)}: {problem}")
    print(f"{len(tests)} tests checked: {bad} problems")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
