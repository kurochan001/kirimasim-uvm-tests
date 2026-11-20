#!/usr/bin/env python3
"""Checks coverage/uvm_reports.json, the per-test permission for the default
report server's UVM_ERROR and UVM_FATAL lines.

The file has one entry only for a test that may print such a line:

    {
      "schema": 1,
      "tests": {
        "u05/test_field_op_rejects_combined_copy_compare_flags": {
          "error": true,
          "fatal": false,
          "basis": ["1800.2-2020 5.7.2.2"]
        }
      }
    }

`error` and `fatal` are permissions, not counts or report identifiers. A test
that may print neither is absent, which is the default. `basis` names the
clause or clauses that require the report; each must be one of the clauses the
test already cites in `:lrm:`.

Usage:
    python3 tools/uvm_reports.py check [--file PATH]
    python3 tools/uvm_reports.py summary [--file PATH]
"""
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))
import suite_results  # noqa: E402

DEFAULT = ROOT / "coverage" / "uvm_reports.json"
SCHEMA = 1
STANDARDS = ("1800.2-2020", "1800-2023")


def load(path: Path) -> dict:
    """The JSON, rejecting a duplicate key instead of keeping the last one."""
    def pairs(items):
        keys = [key for key, _ in items]
        duplicate = next((key for key in keys if keys.count(key) > 1), None)
        if duplicate is not None:
            raise ValueError(f"duplicate key {duplicate!r}")
        return dict(items)
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=pairs)


def lrm(fields: dict[str, str]) -> dict[str, set[str]]:
    """The clause tokens of each standard in a test's :lrm: field."""
    text = fields.get("lrm", "")
    out = {}
    for index, standard in enumerate(STANDARDS):
        start = text.find(standard)
        if start < 0:
            continue
        start += len(standard)
        end = len(text)
        for later in STANDARDS[index + 1:]:
            found = text.find(later, start)
            if found >= 0:
                end = min(end, found)
        out[standard] = {token for token in text[start:end].split()
                         if re.fullmatch(r"(?:[A-Z]\.)?\d+(?:\.\d+)*", token)}
    return out


def problems(data: dict) -> list[str]:
    found = []
    if not isinstance(data, dict):
        return ["the top level is not an object"]
    if set(data) != {"schema", "tests"}:
        found.append("the top level must have exactly 'schema' and 'tests'")
        return found
    if data["schema"] != SCHEMA:
        found.append(f"schema is {data['schema']!r}, expected {SCHEMA}")
    tests = data["tests"]
    if not isinstance(tests, dict):
        found.append("'tests' is not an object")
        return found
    if list(tests) != sorted(tests):
        found.append("the tests are not in sorted order")
    for name, entry in tests.items():
        test = ROOT / "tests" / (name + ".sv")
        if not test.is_file():
            found.append(f"{name}: no such test")
            continue
        fields = suite_results.header(test)
        if fields.get("type") != "simulation":
            found.append(f"{name}: not a simulation test")
        if not isinstance(entry, dict):
            found.append(f"{name}: the entry is not an object")
            continue
        if set(entry) != {"error", "fatal", "basis"}:
            found.append(f"{name}: the entry must have exactly error, fatal, basis")
            continue
        if not isinstance(entry["error"], bool) or not isinstance(entry["fatal"], bool):
            found.append(f"{name}: error and fatal must be booleans")
            continue
        if not entry["error"] and not entry["fatal"]:
            found.append(f"{name}: the entry permits neither severity")
        basis = entry["basis"]
        if not isinstance(basis, list) or not basis:
            found.append(f"{name}: basis must be a non-empty list")
            continue
        if len(set(map(str, basis))) != len(basis):
            found.append(f"{name}: basis has a duplicate")
        cited = lrm(fields)
        for citation in basis:
            if not isinstance(citation, str):
                found.append(f"{name}: a basis is not a string")
                continue
            match = re.fullmatch(
                r"(1800\.2-2020|1800-2023)\s+((?:[A-Z]\.)?\d+(?:\.\d+)*)",
                citation)
            if not match:
                found.append(f"{name}: basis {citation!r} is not '<standard> <clause>'")
                continue
            standard, clause = match.groups()
            if clause not in cited.get(standard, set()):
                found.append(f"{name}: basis {citation!r} is not in :lrm:")
    return found


def summary(data: dict) -> str:
    entries = data.get("tests", {})
    error = sum(entry.get("error") is True for entry in entries.values())
    fatal = sum(entry.get("fatal") is True for entry in entries.values())
    both = sum(entry.get("error") is True and entry.get("fatal") is True
               for entry in entries.values())
    return (f"{len(entries)} tests; error {error}, fatal {fatal}, both {both}; "
            f"error-only {error - both}, fatal-only {fatal - both}")


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("command", choices=("check", "summary"))
    ap.add_argument("--file", type=Path, default=DEFAULT)
    args = ap.parse_args(argv)
    try:
        data = load(args.file)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"{args.file}: {error}", file=sys.stderr)
        return 1
    if args.command == "summary":
        print(summary(data))
        return 0
    found = problems(data)
    for problem in found:
        print(problem)
    if found:
        return 1
    print(f"uvm_reports: {summary(data)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
