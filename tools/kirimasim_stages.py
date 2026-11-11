#!/usr/bin/env python3
"""Checks and uses coverage/kirimasim_stages.json, which gives every test the
bring-up stage of kirimasim that it needs, and short sets of representatives.

Usage:
    python3 tools/kirimasim_stages.py check [--lang en|ja]
    python3 tools/kirimasim_stages.py update
    python3 tools/kirimasim_stages.py summary [--results FILE ...] [--json FILE] [--lang en|ja]
    python3 tools/kirimasim_stages.py list STAGE
    python3 tools/kirimasim_stages.py short [--upto STAGE] [STAGE ...]

The stages order the parts of UVM that a simulator meets while it learns to
run the library:

    0  uvm_pkg only: the package is compiled, elaborated and statically
       initialized; the test uses only package-scope declarations
    1  minimal run_test: objects, components, run_test, phases, objections
       and reports; the stage of any test without a marker of a later stage
    2  factory: type_id, overrides, wrappers, creation by name or type
    3  config_db: the configuration and resource databases
    4  sequence: sequences, sequencers and drivers
    5  TLM: ports, exports, imps, FIFOs, channels and sockets
    6  register layer: register models, maps, memories and adapters

Each of the stages 2 to 6 lists markers, regular expressions that find a use
of its part of UVM in the test's own sources: the test and every file it
collects under tests/ (`:files:` and the files they include), with comments
and string literals removed. The stage of a test is the highest stage whose
marker matches, or 1 when none does. An override, with a reason in English and
Japanese, sets the stage of a test that the markers cannot place; stage 0 is
reached only this way. Every stage compiles the whole of uvm_pkg; a stage
names what the test elaborates and runs beyond it.

check requires one entry for every test, each equal to the stage that the
markers and overrides give, and short sets of simulation tests recorded with
verilator@5.052 whose stage is the listed one. update rewrites the entries
from the markers and overrides and reports what changed; review the change
before committing it. summary counts the tests of each stage and, for each
--results FILE (a runner JSON), the statuses of its current records by stage:
a record whose input fingerprint differs from the current one is counted as
changed, and a test without a record as unmeasured. short prints the paths of
a short set, one per line, for tools/run_kirimasim.py. See
docs/kirimasim-stages.md and its Japanese counterpart.
"""

import argparse
from collections import Counter
import json
from pathlib import Path
import re
import sys

import suite_results

ROOT = Path(__file__).resolve().parent.parent
RECORD = Path("coverage") / "kirimasim_stages.json"
STAGES = range(7)
DEFAULT_STAGE = 1
LANGUAGES = {"en", "ja"}
SIMULATOR = "verilator@5.052"
SOURCE_SUFFIXES = {".sv", ".svh", ".v", ".vh"}
SHORT_MAX = 10
# Comments and string literals, removed before the markers are searched; a
# string is matched first so that "//" inside it does not start a comment.
NOT_CODE = re.compile(r'"(?:\\.|[^"\\\n])*"|//[^\n]*|/\*.*?\*/', re.S)


class StageError(ValueError):
    """The record does not match the tests or its own rules."""


def require(condition, message):
    if not condition:
        raise StageError(message)


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


def read_json(path):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            require(key not in result, f"{path.name}: duplicate JSON key {key}")
            result[key] = value
        return result
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique)


def load(root=None):
    path = (root or ROOT) / RECORD
    require(path.is_file(), f"{RECORD}: missing")
    return read_json(path)


def tests_by_id(root):
    return {suite_results.test_id(path): path for path in suite_results.find_tests(root)}


def code(test, root):
    """The test's own sources with comments and strings removed: the test and
    the files it collects under tests/, not the library."""
    parts = []
    for path in suite_results.input_files(test):
        try:
            relative = path.relative_to(root)
        except ValueError:
            continue
        if relative.parts[0] == "tests" and path.suffix in SOURCE_SUFFIXES and path.is_file():
            parts.append(NOT_CODE.sub(" ", path.read_text(encoding="utf-8", errors="replace")))
    return "\n".join(parts)


def compiled_markers(data):
    return {s["stage"]: [re.compile(m) for m in s["markers"]] for s in data["stages"]}


def rule_stage(text, markers):
    """The highest stage with a matching marker, or the default stage."""
    for stage in sorted(markers, reverse=True):
        if any(m.search(text) for m in markers[stage]):
            return stage
    return DEFAULT_STAGE


def computed(data, root=None):
    """The stage of every current test, and the stage the markers alone give."""
    root = root or ROOT
    markers = compiled_markers(data)
    overrides = data["overrides"]
    stages, by_rule = {}, {}
    for test_id, path in sorted(tests_by_id(root).items()):
        by_rule[test_id] = rule_stage(code(path, root), markers)
        stages[test_id] = overrides[test_id]["stage"] if test_id in overrides else by_rule[test_id]
    return stages, by_rule


def validate_shape(data):
    keys(data, {"schema_version", "standard", "library", "simulator", "purpose", "stages",
                "overrides", "tests"}, "record")
    require(data["schema_version"] == 1, "record: schema_version must be 1")
    require(data["standard"] == "1800.2-2020", "record: standard must be 1800.2-2020")
    require(data["simulator"] == SIMULATOR, f"record: simulator must be {SIMULATOR}")
    bilingual(data["purpose"], "purpose")
    require(isinstance(data["stages"], list), "stages: expected a list")
    require([s.get("stage") if isinstance(s, dict) else None for s in data["stages"]]
            == list(STAGES), "stages: expected stages 0 to 6 in order")
    for s in data["stages"]:
        where = f"stage {s['stage']}"
        keys(s, {"stage", "name", "description", "markers", "short"}, where)
        bilingual(s["name"], f"{where}.name")
        bilingual(s["description"], f"{where}.description")
        require(isinstance(s["markers"], list), f"{where}: markers must be a list")
        if s["stage"] <= DEFAULT_STAGE:
            require(not s["markers"], f"{where}: only stages 2 to 6 have markers")
        else:
            require(s["markers"], f"{where}: needs at least one marker")
        for m in s["markers"]:
            require(isinstance(m, str) and m, f"{where}: a marker must be a regular expression")
            try:
                re.compile(m)
            except re.error as error:
                raise StageError(f"{where}: invalid marker {m!r}: {error}") from None
        require(isinstance(s["short"], list) and 1 <= len(s["short"]) <= SHORT_MAX,
                f"{where}: the short set needs 1 to {SHORT_MAX} tests")
        require(all(isinstance(t, str) for t in s["short"]), f"{where}: short names test ids")
    require(isinstance(data["overrides"], dict), "overrides: expected an object")
    for test_id, o in data["overrides"].items():
        keys(o, {"stage", "reason"}, f"overrides.{test_id}")
        require(o["stage"] in STAGES, f"overrides.{test_id}: stage must be 0 to 6")
        bilingual(o["reason"], f"overrides.{test_id}.reason")
    require(isinstance(data["tests"], dict), "tests: expected an object")
    require(list(data["tests"]) == sorted(data["tests"]), "tests: must be sorted by test id")


def locked_version(root):
    lock = json.loads((root / "third_party" / "uvm.lock").read_text(encoding="utf-8"))
    return lock["version"]


def validate(data, root=None):
    """Raises StageError unless the record matches the current tests."""
    root = root or ROOT
    validate_shape(data)
    require(data["library"] == locked_version(root),
            f"record: library must be the locked version {locked_version(root)}")
    current = tests_by_id(root)
    for test_id in data["overrides"]:
        require(test_id in current, f"overrides.{test_id}: no such test")
    stages, by_rule = computed(data, root)
    for test_id, o in data["overrides"].items():
        require(o["stage"] != by_rule[test_id],
                f"overrides.{test_id}: the markers already give stage {o['stage']}")
    missing = sorted(set(stages) - set(data["tests"]))
    extra = sorted(set(data["tests"]) - set(stages))
    require(not missing, f"{len(missing)} tests have no stage, e.g. {missing[:3]}; run update")
    require(not extra, f"{len(extra)} entries name no test, e.g. {extra[:3]}; run update")
    differ = sorted(t for t in stages if data["tests"][t] != stages[t])
    require(not differ, f"{len(differ)} entries differ from the markers and overrides, "
                        f"e.g. {differ[:3]}; run update and review the change")
    seen = set()
    for s in data["stages"]:
        for test_id in s["short"]:
            where = f"stage {s['stage']} short set: {test_id}"
            require(test_id not in seen, f"{where}: listed twice")
            seen.add(test_id)
            require(test_id in current, f"{where}: no such test")
            fields = suite_results.header(current[test_id])
            require(fields.get("type") == "simulation", f"{where}: not a simulation test")
            require(SIMULATOR in fields.get("oracle", "").split(),
                    f"{where}: not recorded with {SIMULATOR}")
            # Every short set is nonempty, so every stage keeps at least one test.
            require(stages[test_id] == s["stage"], f"{where}: its stage is {stages[test_id]}")
    return stages


def update(root=None):
    """Rewrites the entries from the markers and overrides; returns the changes."""
    root = root or ROOT
    data = load(root)
    validate_shape({**data, "tests": {}})
    stages, _ = computed(data, root)
    old = data["tests"]
    changes = {"added": sorted(set(stages) - set(old)), "removed": sorted(set(old) - set(stages)),
               "changed": sorted(t for t in stages if t in old and old[t] != stages[t])}
    data["tests"] = stages
    write_json(root / RECORD, data)
    return changes


def result_tests(path):
    data = read_json(path)
    require(isinstance(data, dict) and isinstance(data.get("tests"), dict),
            f"{path.name}: not a runner JSON with tests")
    return data


def summary(data, results=(), root=None):
    root = root or ROOT
    current = tests_by_id(root)
    by_stage = {stage: sorted(t for t, s in data["tests"].items() if s == stage)
                for stage in STAGES}
    rows = []
    for stage in STAGES:
        names = by_stage[stage]
        tagged = sum(SIMULATOR in suite_results.header(current[t]).get("oracle", "").split()
                     for t in names)
        rows.append({"stage": stage, "name": data["stages"][stage]["name"], "tests": len(names),
                     "verilator_tagged": tagged, "short": len(data["stages"][stage]["short"])})
    files = []
    for path in results:
        record = result_tests(path)
        digests = {}
        per_stage = []
        for stage in STAGES:
            statuses, reasons = Counter(), Counter()
            for test_id in by_stage[stage]:
                entry = record["tests"].get(test_id)
                if entry is None:
                    statuses["unmeasured"] += 1
                    continue
                recorded = entry.get("inputs_sha256")
                if entry.get("inputs_changed"):
                    statuses["changed"] += 1
                    continue
                if recorded is not None:
                    if test_id not in digests:
                        digests[test_id] = suite_results.input_digest(current[test_id])
                    if recorded != digests[test_id]:
                        statuses["changed"] += 1
                        continue
                statuses[entry["status"]] += 1
                if entry.get("reason"):
                    reasons[entry["reason"]] += 1
            per_stage.append({"stage": stage, "statuses": dict(sorted(statuses.items())),
                              "top_reason": (reasons.most_common(1)[0][0] if reasons else None)})
        files.append({"file": path.name, "simulator": record.get("simulator"),
                      "by_stage": per_stage})
    return {"tests": len(data["tests"]), "stages": rows, "results": files}


def short_paths(data, stages):
    return [f"tests/{t}.sv" for stage in stages for t in data["stages"][stage]["short"]]


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def print_summary(s, lang):
    for row in s["stages"]:
        name = row["name"][lang]
        if lang == "en":
            print(f"stage {row['stage']} ({name}): {row['tests']} tests, "
                  f"{row['verilator_tagged']} recorded with {SIMULATOR}, short set {row['short']}")
        else:
            print(f"段階{row['stage']}（{name}）：テスト{row['tests']}件・{SIMULATOR}で記録済み"
                  f"{row['verilator_tagged']}件・短いセット{row['short']}件")
    for f in s["results"]:
        print(f"{f['file']} ({f['simulator']}):" if lang == "en"
              else f"{f['file']}（{f['simulator']}）：")
        for row in f["by_stage"]:
            counts = ", ".join(f"{k} {v}" for k, v in row["statuses"].items())
            reason = row["top_reason"]
            if lang == "en":
                print(f"  stage {row['stage']}: {counts}"
                      + (f"; most common reason: {reason}" if reason else ""))
            else:
                print(f"  段階{row['stage']}：{counts}"
                      + (f"；最も多い理由：{reason}" if reason else ""))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=("check", "update", "summary", "list", "short"))
    parser.add_argument("stages", nargs="*", type=int, help="stages (list, short)")
    parser.add_argument("--upto", type=int, help="every stage up to this one (short)")
    parser.add_argument("--results", type=Path, nargs="+", default=[],
                        help="runner JSON files (summary)")
    parser.add_argument("--json", type=Path, help="write the summary as JSON")
    parser.add_argument("--lang", choices=("en", "ja"), default="en")
    args = parser.parse_args(argv)
    if args.command == "list" and len(args.stages) != 1:
        parser.error("list takes one stage")
    if args.command not in ("list", "short") and args.stages:
        parser.error("stages are for list or short")
    if args.upto is not None and (args.command != "short" or args.stages):
        parser.error("--upto is for short, without stages")
    if any(stage not in STAGES for stage in [*args.stages, *([args.upto] if args.upto else [])]):
        parser.error("a stage is 0 to 6")
    if args.results and args.command != "summary":
        parser.error("--results is for summary")
    if args.json is not None and args.command != "summary":
        parser.error("--json is for summary")
    if args.json is not None and args.json.resolve() == (ROOT / RECORD).resolve():
        parser.error("generated output cannot overwrite the record")
    try:
        if args.command == "update":
            changes = update()
            print(", ".join(f"{k} {len(v)}" for k, v in changes.items()))
            for kind, names in changes.items():
                for name in names:
                    print(f"  {kind}: {name}")
            return 0
        data = load()
        if args.command == "check":
            stages = validate(data)
            print(f"{len(stages)} tests have their stage; the short sets match"
                  if args.lang == "en" else f"テスト{len(stages)}件の段階と短いセットが記録と一致します")
        elif args.command == "summary":
            validate(data)
            s = summary(data, args.results)
            if args.json:
                write_json(args.json, s)
            print_summary(s, args.lang)
        elif args.command == "list":
            for test_id, stage in data["tests"].items():
                if stage == args.stages[0]:
                    print(test_id)
        else:
            stages = list(range(args.upto + 1)) if args.upto is not None else (
                args.stages or list(STAGES))
            print("\n".join(short_paths(data, stages)))
    except (StageError, OSError, json.JSONDecodeError) as error:
        print(f"kirimasim_stages: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
