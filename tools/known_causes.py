#!/usr/bin/env python3
"""Checks and summarizes coverage/known_causes.json, the record of why each
known difference of the ordinary Verilator 5.052 run does not reach its
expectation.

Usage:
    python3 tools/known_causes.py check [--results FILE] [--lang en|ja]
    python3 tools/known_causes.py summary [--json FILE] [--lang en|ja]
    python3 tools/known_causes.py candidates [--json FILE] [--lang en|ja]
    python3 tools/known_causes.py reproduce [--verilator PATH]

A known difference is a two-state test (`:fourstate: no`) whose `:oracle:`
does not list verilator@5.052 (tools/run_verilator.py). The record has exactly
one entry for each of them and none for any other test. An entry names the
kind of difference (runtime, build or accepted-illegal), the DPI condition
that the test needs, if any, and one cause:

    library         the pinned UVM library differs from the cited clauses
    interpretation  the cited text admits another reading, which the library
                    follows; the test takes the first of the two readings
    simulator       Verilator differs from IEEE 1800-2023; a reproducer
                    without UVM shows the difference
    condition       the test needs a DPI condition that the ordinary run does
                    not link, and it matches under that condition's runner
    unassigned      not diagnosed yet

The evidence of each cause is checked against the repository: library files
and the text that each names must exist in the pinned library, clauses must be
listed in tools/clauses_1800_2.txt, controls must be tagged tests, and the
recorded input fingerprint must equal the current one, so a changed test needs
a new diagnosis. With --results, the known records of a combined runner JSON
must be exactly the entries, with the same kinds and fingerprints.

summary counts the entries by cause and separates the kirimasim targets:
inputs that measure a simulator against the standard, and inputs that the
pinned library itself keeps from the expectation on any simulator (library and
interpretation causes). The measurable inputs include the tests recorded with
Verilator, the simulator and condition causes, and the four-state tests, which
have no Verilator record; unassigned entries are counted apart until they are
diagnosed. candidates lists the entries for human review.
reproduce builds every simulator reproducer with Verilator and checks that
Verilator still accepts or rejects it as recorded.

The record never changes an expectation, which follows the standard. Causes
are diagnosed after the expectation is frozen and keep review status ai until
a person checks them. See docs/known-differences.md and its Japanese
counterpart.
"""

import argparse
from collections import Counter
import datetime
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import suite_results

ROOT = Path(__file__).resolve().parent.parent
RECORD = Path("coverage") / "known_causes.json"
STANDARD = "1800.2-2020"
SIMULATOR = "verilator@5.052"
LANGUAGES = {"en", "ja"}
KINDS = ("runtime", "build", "accepted-illegal")
CAUSES = ("library", "interpretation", "simulator", "condition", "unassigned")
# The causes for which the pinned library itself keeps every simulator from the
# expectation: an interpretation entry exists because the library follows the
# other reading.
LIBRARY_BLOCKED = ("library", "interpretation")
# The causes a person should check, in the order they are listed for review.
REVIEW_ORDER = ("interpretation", "library", "simulator")
CONDITIONS = {"hdl": "uvm_hdl_backend", "cmdline": "uvm_cmdline_backend"}
BEHAVIORS = ("accepts", "rejects")
CLAUSE = re.compile(r"[0-9A-Z]+(\.[0-9]+)*")
DIGEST = re.compile(r"[0-9a-f]{64}")


class CauseError(ValueError):
    """The record does not match the tests or its own rules."""


def require(condition, message):
    if not condition:
        raise CauseError(message)


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


def validate_review(review, where):
    keys(review, {"status", "reviewer", "reviewed_at"}, f"{where}.review")
    require(review["status"] in ("ai", "human"), f"{where}: invalid review")
    if review["status"] == "human":
        require(isinstance(review["reviewer"], str) and review["reviewer"].strip(),
                f"{where}: human review needs an identified reviewer")
        try:
            datetime.date.fromisoformat(review["reviewed_at"])
        except (ValueError, TypeError):
            raise CauseError(f"{where}: human review needs an ISO review date") from None
    else:
        require(review["reviewer"] is None and review["reviewed_at"] is None,
                f"{where}: AI review must not carry human-review fields")


def read_json(path):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            require(key not in result, f"{path.name}: duplicate JSON key {key}")
            result[key] = value
        return result
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique)


def clause_list(root):
    lines = (root / "tools" / "clauses_1800_2.txt").read_text(encoding="utf-8").splitlines()
    return {line.strip() for line in lines if line.strip() and not line.startswith("#")}


def library_dir(root):
    lock = json.loads((root / "third_party" / "uvm.lock").read_text(encoding="utf-8"))
    return root / "third_party" / "uvm" / lock["version"], lock["version"]


def tests_by_id(root):
    return {suite_results.test_id(path): path for path in suite_results.find_tests(root)}


def is_tagged(fields):
    return SIMULATOR in fields.get("oracle", "").split()


def expected_entries(tests):
    """The tests that need an entry: two-state tests not recorded with Verilator."""
    result = {}
    for name, path in tests.items():
        fields = suite_results.header(path)
        if fields.get("fourstate") == "no" and not is_tagged(fields):
            result[name] = fields
    return result


def required_condition(fields):
    found = [name for name, field in CONDITIONS.items() if fields.get(field) == "vpi"]
    require(len(found) <= 1, "a test selects more than one DPI condition")
    return found[0] if found else None


def validate_clauses(values, where, known):
    require(isinstance(values, list) and values, f"{where}: at least one clause is required")
    for clause in values:
        require(isinstance(clause, str) and clause in known,
                f"{where}: {clause!r} is not an IEEE {STANDARD} clause")


def validate_controls(values, where, tests):
    require(isinstance(values, list) and values, f"{where}: controls must be a non-empty list")
    for name in values:
        require(name in tests, f"{where}: control {name} is not a test")
        require(is_tagged(suite_results.header(tests[name])),
                f"{where}: control {name} is not recorded with {SIMULATOR}")


def validate_reproducers(reproducers, where):
    require(isinstance(reproducers, dict), f"{where}: expected an object")
    for name, value in reproducers.items():
        here = f"{where}.{name}"
        require(re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", name),
                f"{here}: names are lower-case words joined by hyphens")
        keys(value, {"clauses_1800_2023", "source", "conforming", "verilator", "explanation"},
             here)
        clauses = value["clauses_1800_2023"]
        require(isinstance(clauses, list) and clauses
                and all(isinstance(c, str) and CLAUSE.fullmatch(c) for c in clauses),
                f"{here}: clauses_1800_2023 must be clause numbers")
        source = value["source"]
        require(isinstance(source, list) and all(isinstance(line, str) for line in source),
                f"{here}: source must be a list of lines")
        modules = [m.group(1) for line in source
                   for m in [re.match(r"module\s+(\w+)\s*;", line)] if m]
        require(modules == [name.replace("-", "_")],
                f"{here}: the source must declare one module named {name.replace('-', '_')}")
        require("uvm" not in "\n".join(source).lower(),
                f"{here}: a reproducer must not use UVM")
        require(value["conforming"] in BEHAVIORS and value["verilator"] in BEHAVIORS
                and value["conforming"] != value["verilator"],
                f"{here}: conforming and verilator must be different values of "
                + "/".join(BEHAVIORS))
        bilingual(value["explanation"], f"{here}.explanation")


def validate_evidence(entry, where, *, clauses, library, tests, reproducers, used):
    cause, evidence = entry["cause"], entry["evidence"]
    if cause in ("condition", "unassigned"):
        require(evidence == {}, f"{where}: {cause} entries carry no evidence")
        return
    if cause == "library":
        keys(evidence, {"clauses", "library"}, f"{where}.evidence", ("controls", "deviations"))
        validate_clauses(evidence["clauses"], f"{where}.evidence", clauses)
        sites = evidence["library"]
        require(isinstance(sites, list) and sites, f"{where}: library sites are required")
        for site in sites:
            keys(site, {"file", "text"}, f"{where}.evidence.library")
            path = library / site["file"]
            require(site["file"].startswith("src/") and path.is_file(),
                    f"{where}: {site['file']} is not a file of the pinned library")
            require(isinstance(site["text"], str) and site["text"]
                    and site["text"] in path.read_text(encoding="utf-8", errors="replace"),
                    f"{where}: {site['file']} does not contain {site['text']!r}")
        if "deviations" in evidence:
            require(isinstance(evidence["deviations"], int) and evidence["deviations"] > 0,
                    f"{where}: deviations is an issue number of DEVIATIONS.md")
    elif cause == "interpretation":
        keys(evidence, {"clauses", "readings"}, f"{where}.evidence", ("controls",))
        validate_clauses(evidence["clauses"], f"{where}.evidence", clauses)
        readings = evidence["readings"]
        require(isinstance(readings, list) and len(readings) == 2,
                f"{where}: an interpretation has the test's reading and one other")
        for n, reading in enumerate(readings):
            bilingual(reading, f"{where}.evidence.readings[{n}]")
    else:
        keys(evidence, {"reproducer"}, f"{where}.evidence", ("controls",))
        require(evidence["reproducer"] in reproducers,
                f"{where}: reproducer {evidence['reproducer']!r} is not defined")
        used.add(evidence["reproducer"])
    if "controls" in evidence:
        validate_controls(evidence["controls"], f"{where}.evidence", tests)


def load(root=None):
    root = root or ROOT
    data = read_json(root / RECORD)
    validate(data, root)
    return data


def validate(data, root=None):
    root = root or ROOT
    keys(data, {"schema_version", "standard", "library", "simulator", "status",
                "reproducers", "causes"}, RECORD.name)
    require(data["schema_version"] == 1, "unsupported schema_version")
    require(data["standard"] == STANDARD, f"standard must be {STANDARD}")
    library, version = library_dir(root)
    require(data["library"] == version, f"library must be the pinned UVM {version}")
    require(data["simulator"] == SIMULATOR, f"simulator must be {SIMULATOR}")
    require(library.is_dir(), f"the pinned library is not at {library}; run tools/fetch_uvm.py")
    validate_reproducers(data["reproducers"], "reproducers")
    tests = tests_by_id(root)
    wanted = expected_entries(tests)
    clauses = clause_list(root)
    causes = data["causes"]
    require(isinstance(causes, list), "causes must be a list")
    names = [entry.get("test") if isinstance(entry, dict) else None for entry in causes]
    require(names == sorted(set(names), key=str), "causes must be sorted by test, without repeats")
    used = set()
    for n, entry in enumerate(causes):
        keys(entry, {"test", "inputs_sha256", "kind", "cause", "evidence", "note", "review"},
             f"causes[{n}]", ("condition",))
        name = entry["test"]
        where = f"causes[{name}]"
        require(name in tests, f"{where}: no such test")
        require(name in wanted, f"{where}: the test is four-state or recorded with {SIMULATOR}")
        fields = wanted[name]
        digest = entry["inputs_sha256"]
        require(isinstance(digest, str) and DIGEST.fullmatch(digest),
                f"{where}: inputs_sha256 must be a SHA-256 digest")
        require(entry["inputs_sha256"] == suite_results.input_digest(tests[name]),
                f"{where}: the inputs changed after the diagnosis; diagnose the test again")
        require(entry["kind"] in KINDS, f"{where}: kind must be one of {', '.join(KINDS)}")
        illegal = "should_fail_because" in fields
        require((entry["kind"] == "accepted-illegal") <= illegal and
                (entry["kind"] == "runtime") <= (not illegal),
                f"{where}: kind {entry['kind']} does not fit :should_fail_because:")
        condition = required_condition(fields)
        require(entry.get("condition") == condition,
                f"{where}: condition must be {condition}" if condition
                else f"{where}: the test selects no DPI condition")
        require(entry["cause"] in CAUSES, f"{where}: cause must be one of {', '.join(CAUSES)}")
        require(entry["cause"] != "condition" or condition,
                f"{where}: only a test that selects a DPI condition can have cause condition")
        validate_evidence(entry, where, clauses=clauses, library=library, tests=tests,
                          reproducers=data["reproducers"], used=used)
        if entry["cause"] == "unassigned":
            require(entry["note"] is None, f"{where}: an unassigned entry has no note yet")
        else:
            bilingual(entry["note"], f"{where}.note")
        validate_review(entry["review"], where)
    missing = sorted(set(wanted) - set(names))
    require(not missing, f"{len(missing)} known differences have no entry, e.g. {missing[:3]}")
    unused = sorted(set(data["reproducers"]) - used)
    require(not unused, f"reproducers not used by any entry: {', '.join(unused)}")
    unassigned = sum(entry["cause"] == "unassigned" for entry in causes)
    require(data["status"] == ("partial" if unassigned else "complete"),
            "status must be partial while an entry is unassigned, and complete otherwise")


def result_kind(reason):
    if reason.startswith("build failed"):
        return "build"
    if reason.startswith("the design was accepted, but it is illegal"):
        return "accepted-illegal"
    if re.match(r"seed \d+: ", reason):
        return "runtime"
    return None


def check_results(data, path):
    results = read_json(path)
    require(results.get("simulator") == "verilator" and "5.052" in results.get("version", ""),
            f"{path.name}: not a Verilator 5.052 record")
    known = {name: record for name, record in results["tests"].items()
             if record["status"] == "known"}
    entries = {entry["test"]: entry for entry in data["causes"]}
    require(set(known) == set(entries),
            f"{path.name}: {len(set(known) - set(entries))} known records without an entry, "
            f"{len(set(entries) - set(known))} entries that are not known records")
    for name, record in known.items():
        entry = entries[name]
        require(result_kind(record.get("reason", "")) == entry["kind"],
                f"{name}: the record is not a {entry['kind']} difference")
        require(record.get("inputs_sha256") == entry["inputs_sha256"],
                f"{name}: the record was measured with other inputs")
    return len(known)


def summary(data, root=None):
    root = root or ROOT
    tests = tests_by_id(root)
    two_state = [n for n, p in tests.items() if suite_results.header(p).get("fourstate") == "no"]
    tagged = [n for n in two_state if is_tagged(suite_results.header(tests[n]))]
    causes = Counter(entry["cause"] for entry in data["causes"])
    kinds = Counter((entry["cause"], entry["kind"]) for entry in data["causes"])
    blocked = sum(causes[c] for c in LIBRARY_BLOCKED)
    return {
        "tests": len(tests),
        "four_state_without_verilator_record": len(tests) - len(two_state),
        "verilator_tagged": len(tagged),
        "known": len(data["causes"]),
        "by_cause": {c: causes[c] for c in CAUSES},
        "by_cause_and_kind": {c: {k: kinds[(c, k)] for k in KINDS} for c in CAUSES},
        "with_condition": sum(1 for e in data["causes"] if e.get("condition")),
        "kirimasim_targets": {
            "measurable": len(tests) - blocked - causes["unassigned"],
            "blocked_by_pinned_library": blocked,
            "not_yet_classified": causes["unassigned"],
        },
    }


def candidates(data):
    order = {cause: n for n, cause in enumerate(REVIEW_ORDER)}
    chosen = [e for e in data["causes"] if e["cause"] in order and e["review"]["status"] == "ai"]
    chosen.sort(key=lambda e: (order[e["cause"]], e["test"]))
    return [{"test": e["test"], "cause": e["cause"], "kind": e["kind"],
             "clauses": e["evidence"].get("clauses", []),
             "reproducer": e["evidence"].get("reproducer"), "note": e["note"]} for e in chosen]


def reproduce(data, verilator):
    failures = []
    for name, value in sorted(data["reproducers"].items()):
        module = name.replace("-", "_")
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / f"{module}.sv"
            source.write_text("\n".join(value["source"]) + "\n", encoding="utf-8")
            build = subprocess.run(
                [verilator, "--binary", "--timing", "-Wno-fatal", "-Wno-lint", "-Wno-style",
                 "-Mdir", str(Path(tmp) / "obj"), str(source)],
                capture_output=True, text=True, errors="replace", timeout=600)
            behavior = "accepts" if build.returncode == 0 else "rejects"
            if behavior == "accepts":
                run = subprocess.run([str(Path(tmp) / "obj" / f"V{module}")], capture_output=True,
                                     text=True, errors="replace", timeout=60)
                behavior = "accepts" if run.returncode == 0 else "rejects"
        first = next((line for line in build.stderr.splitlines() if "%Error" in line), "")
        print(f"{name}: Verilator {behavior}" + (f" ({first.strip()})" if first else ""))
        if behavior != value["verilator"]:
            failures.append(name)
    return failures


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def print_summary(s, lang):
    c, t = s["by_cause"], s["kirimasim_targets"]
    if lang == "en":
        print(f"{s['tests']} tests: {s['verilator_tagged']} recorded with {SIMULATOR}, "
              f"{s['known']} known differences, {s['four_state_without_verilator_record']} "
              "four-state without a Verilator record")
        print("Known differences by cause: " + ", ".join(f"{k} {v}" for k, v in c.items())
              + f" ({s['with_condition']} need a DPI condition)")
        print(f"kirimasim targets: {t['measurable']} measurable against the standard, "
              f"{t['blocked_by_pinned_library']} kept from the expectation by the pinned library, "
              f"{t['not_yet_classified']} not yet classified")
    else:
        print(f"テスト{s['tests']}件：{SIMULATOR}で記録済み{s['verilator_tagged']}件・"
              f"既知の違い{s['known']}件・Verilatorの記録がない4値"
              f"{s['four_state_without_verilator_record']}件")
        names = {"library": "library", "interpretation": "interpretation",
                 "simulator": "simulator", "condition": "実行条件", "unassigned": "未分類"}
        print("既知の違いの原因：" + "・".join(f"{names[k]} {v}件" for k, v in c.items())
              + f"（DPIの実行条件が要るもの{s['with_condition']}件）")
        print(f"kirimasimの目標：規格の期待値で測れる入力{t['measurable']}件・"
              f"固定版libraryのために期待値に届かない入力{t['blocked_by_pinned_library']}件・"
              f"未分類{t['not_yet_classified']}件")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=("check", "summary", "candidates", "reproduce"))
    parser.add_argument("--results", type=Path, help="a combined Verilator runner JSON (check)")
    parser.add_argument("--json", type=Path, help="write the summary or candidates as JSON")
    parser.add_argument("--verilator", default="verilator", help="Verilator (reproduce)")
    parser.add_argument("--lang", choices=("en", "ja"), default="en")
    args = parser.parse_args(argv)
    if args.results is not None and args.command != "check":
        parser.error("--results is for check")
    if args.json is not None and args.command not in ("summary", "candidates"):
        parser.error("--json is for summary or candidates")
    if args.json is not None and args.json.resolve() == (ROOT / RECORD).resolve():
        parser.error("generated output cannot overwrite the record")
    try:
        data = load()
        if args.command == "check":
            print(f"{len(data['causes'])} entries match the tests"
                  if args.lang == "en" else f"{len(data['causes'])}件の記録がテストと一致します")
            if args.results is not None:
                n = check_results(data, args.results)
                print(f"{n} known records of {args.results.name} match the entries"
                      if args.lang == "en"
                      else f"{args.results.name}のknown {n}件が記録と一致します")
        elif args.command == "summary":
            s = summary(data)
            if args.json:
                write_json(args.json, s)
            print_summary(s, args.lang)
        elif args.command == "candidates":
            rows = candidates(data)
            if args.json:
                write_json(args.json, rows)
            for n, row in enumerate(rows, 1):
                where = " ".join(row["clauses"]) or row["reproducer"]
                print(f"{n}. {row['test']} [{row['cause']}, {row['kind']}, {where}]: "
                      f"{row['note'][args.lang]}")
        else:
            if shutil.which(args.verilator) is None:
                parser.error(f"{args.verilator} is not found")
            failures = reproduce(data, args.verilator)
            if failures:
                print("Verilator no longer behaves as recorded: " + ", ".join(failures)
                      if args.lang == "en"
                      else "記録と異なる動作になった再現例：" + "、".join(failures),
                      file=sys.stderr)
                return 1
        return 0
    except (CauseError, OSError, ValueError, KeyError, TypeError) as exc:
        print(f"known_causes: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
