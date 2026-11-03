#!/usr/bin/env python3
"""Validate the draft requirement ledger and inventory clause references.

This inventories references and explicit expected-output links, not conformance
or an approved coverage percentage. See docs/requirements.md and its Japanese
counterpart. Simulator results are deliberately not consumed here.
"""

import argparse
from collections import Counter, defaultdict
import datetime
import hashlib
import json
from pathlib import Path
import re
import sys

import suite_results

ROOT = Path(__file__).resolve().parent.parent
STANDARD = "1800.2-2020"
LANGUAGES = {"en", "ja"}


class LedgerError(ValueError):
    """A ledger or its binding to current tests needs correction."""


def require(condition, message):
    if not condition:
        raise LedgerError(message)


def keys(value, expected, where):
    require(isinstance(value, dict) and set(value) == set(expected),
            f"{where}: expected fields {', '.join(sorted(expected))}")


def bilingual(value, where):
    keys(value, LANGUAGES, where)
    require(all(isinstance(text, str) and text.strip() for text in value.values()),
            f"{where}: both en and ja text are required")


def validate_review(review, where, *, applied=False):
    keys(review, {"status", "reviewer", "reviewed_at"}, f"{where}.review")
    allowed = ("ai", "human") if applied else ("ai", "human", "unreviewed")
    require(review["status"] in allowed, f"{where}: invalid review")
    if review["status"] == "human":
        require(isinstance(review["reviewer"], str) and review["reviewer"].strip(),
                f"{where}: human review needs an identified reviewer")
        try:
            datetime.date.fromisoformat(review["reviewed_at"])
        except (ValueError, TypeError):
            raise LedgerError(f"{where}: human review needs an ISO review date") from None
    else:
        require(review["reviewer"] is None and review["reviewed_at"] is None,
                f"{where}: non-human review must not carry human-review fields")


def read_json(path):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            require(key not in result, f"{path.name}: duplicate JSON key {key}")
            result[key] = value
        return result
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique)


def load(root=None):
    root = root or ROOT
    catalog = root / "tools/clauses_1800_2.txt"
    clauses = [line.strip() for line in catalog.read_text().splitlines()
               if line.strip() and not line.startswith("#")]
    require(len(clauses) == len(set(clauses)), "clause catalog contains duplicate identifiers")
    require(all(re.fullmatch(r"(?:[1-9][0-9]*|[B-H])(?:\.[0-9]+)*", c) for c in clauses),
            "clause catalog contains an invalid identifier")
    files = {p.relative_to(root / "tests").with_suffix("").as_posix(): p
             for p in suite_results.find_tests(root)}
    tests = {}
    for name, path in files.items():
        standard = None
        references = []
        for token in suite_results.header(path).get("lrm", "").split():
            if token in (STANDARD, "1800-2023"):
                standard = token
            elif standard == STANDARD:
                require(token in clauses, f"{name}: unknown UVM clause {token}")
                if token not in references:
                    references.append(token)
        require(references, f"{name}: no UVM clause reference")
        fields = suite_results.header(path)
        tests[name] = {"primary_clause": references[0], "references": references,
                       "inputs_sha256": suite_results.input_digest(path),
                       "spec_check": fields.get("spec_check"),
                       "oracle": fields.get("oracle", "").split()}
    return {"root": root, "clauses": clauses, "tests": tests, "files": files,
            "catalog_sha256": hashlib.sha256(catalog.read_bytes()).hexdigest(),
            "scope": read_json(root / "coverage/scope.json"),
            "ledger": read_json(root / "coverage/requirements.json"),
            "assessments": read_json(root / "coverage/assessments.json"),
            "index": read_json(root / "coverage/test_index.json")}


def validate(data, *, check_index=True):
    scope, ledger, index = data["scope"], data["ledger"], data["index"]
    keys(scope, {"schema_version", "standard", "status", "normative_inventory_complete",
                 "approved_denominator", "counting_unit", "candidate_roots", "context_roots",
                 "deferred_roots", "legacy_clause_target"}, "scope")
    require(scope["schema_version"] == 1 and scope["standard"] == STANDARD,
            "scope: unsupported schema or standard")
    require(scope["status"] == "proposed" and scope["normative_inventory_complete"] is False
            and scope["approved_denominator"] is None,
            "scope: schema 1 supports an unapproved, incomplete proposal only")
    bilingual(scope["counting_unit"], "scope.counting_unit")
    require(type(scope["legacy_clause_target"]) is int and scope["legacy_clause_target"] > 0,
            "scope: legacy_clause_target must be a positive integer")
    candidates, context, deferred = (scope["candidate_roots"], scope["context_roots"],
                                     scope["deferred_roots"])
    require(isinstance(candidates, list) and isinstance(context, list)
            and isinstance(deferred, dict), "scope: invalid root groups")
    groups = [*candidates, *context, *deferred]
    require(all(isinstance(c, str) for c in groups) and len(groups) == len(set(groups)),
            "scope: duplicate or invalid root assignment")
    require(set(groups) == {c.split(".")[0] for c in data["clauses"]},
            "scope: every catalog root must have exactly one disposition")
    for chapter, reason in deferred.items():
        bilingual(reason, f"scope.deferred_roots.{chapter}")

    keys(ledger, {"schema_version", "standard", "status", "requirements"}, "ledger")
    require(ledger["schema_version"] == 1 and ledger["standard"] == STANDARD
            and ledger["status"] == "partial", "ledger: expected a partial schema 1 ledger")
    require(isinstance(ledger["requirements"], list), "ledger.requirements must be an array")
    ids = set()
    for entry in ledger["requirements"]:
        keys(entry, {"id", "clause", "statement", "conditions", "expected", "limitations",
                     "review", "test_links"}, "requirement")
        name = entry["id"]
        require(isinstance(name, str) and re.fullmatch(r"UVM-[A-Z0-9]+(?:-[A-Z0-9]+)*", name),
                "requirement: invalid stable ID")
        require(name not in ids, f"{name}: duplicate requirement ID")
        ids.add(name)
        require(entry["clause"] in data["clauses"], f"{name}: unknown clause")
        for field in ("statement", "conditions", "expected", "limitations"):
            bilingual(entry[field], f"{name}.{field}")
        validate_review(entry["review"], name)
        require(isinstance(entry["test_links"], list), f"{name}: test_links must be an array")
        linked = set()
        for link in entry["test_links"]:
            keys(link, {"test", "role", "expected_observations"}, f"{name}.test_link")
            test = link["test"]
            require(isinstance(test, str) and test in data["tests"],
                    f"{name}: unknown test {test}")
            require(test not in linked, f"{name}: duplicate test link {test}")
            linked.add(test)
            require(link["role"] in ("direct", "control"), f"{name}: invalid link role")
            if link["role"] == "direct":
                require(entry["clause"] in data["tests"][test]["references"],
                        f"{name}: direct test {test} does not cite the requirement clause")
            anchors = link["expected_observations"]
            require(isinstance(anchors, list) and anchors
                    and all(isinstance(a, str) for a in anchors)
                    and len(set(anchors)) == len(anchors),
                    f"{name}: expected observations must be a nonempty distinct list")
            expected = (suite_results.expected_output(data["files"][test]) or "").splitlines()
            require(all(isinstance(a, str) and a.startswith("UT: ") and a in expected
                        for a in anchors), f"{name}: observation is not in {test}'s expectation")

    assessments = data["assessments"]
    keys(assessments, {"schema_version", "standard", "status", "assessments"}, "assessments")
    require(assessments["schema_version"] == 1 and assessments["standard"] == STANDARD
            and assessments["status"] == "partial", "assessments: expected partial schema 1")
    require(isinstance(assessments["assessments"], list), "assessments must be an array")
    assessed = set()
    requirement_clauses = {e["clause"] for e in ledger["requirements"]}
    for entry in assessments["assessments"]:
        keys(entry, {"clause", "classification", "rationale", "related_requirements", "review"},
             "assessment")
        clause = entry["clause"]
        require(isinstance(clause, str) and clause in data["clauses"],
                "assessment: unknown clause")
        require(clause not in assessed, f"{clause}: duplicate assessment")
        assessed.add(clause)
        require(clause not in requirement_clauses,
                f"{clause}: assessment conflicts with requirement decomposition")
        require(entry["classification"] in ("structural", "contextual"),
                f"{clause}: invalid classification")
        bilingual(entry["rationale"], f"{clause}.rationale")
        validate_review(entry["review"], clause, applied=True)
        related = entry["related_requirements"]
        require(isinstance(related, list) and all(isinstance(i, str) and i in ids for i in related)
                and len(related) == len(set(related)), f"{clause}: invalid related requirements")
        require(bool(related) == (entry["classification"] == "contextual"),
                f"{clause}: contextual assessments need related requirements; structural need none")

    keys(index, {"schema_version", "standard", "tests"}, "test index")
    require(index["schema_version"] == 1 and index["standard"] == STANDARD
            and isinstance(index["tests"], dict), "test index: unsupported schema or standard")
    for name, snapshot in index["tests"].items():
        keys(snapshot, {"primary_clause", "inputs_sha256"}, f"index.{name}")
        require(isinstance(snapshot["inputs_sha256"], str)
                and re.fullmatch(r"[0-9a-f]{64}", snapshot["inputs_sha256"]),
                f"{name}: invalid input fingerprint")
        require(snapshot["primary_clause"] in data["clauses"], f"{name}: unknown indexed clause")
    if check_index:
        missing = sorted(data["tests"].keys() - index["tests"].keys())
        removed = sorted(index["tests"].keys() - data["tests"].keys())
        require(not missing and not removed,
                f"test index: missing={missing}, removed={removed}; review a sync proposal")
        for name, current in data["tests"].items():
            require(index["tests"][name] == snapshot_for(current),
                    f"{name}: stale index fingerprint/focus; recheck its mappings")


def snapshot_for(test):
    return {key: test[key] for key in ("primary_clause", "inputs_sha256")}


def ledger_digest(data):
    """Portable semantic identity of scope, obligations, assessments, index and catalog."""
    inputs = {key: data[key] for key in
              ("scope", "ledger", "assessments", "index", "catalog_sha256")}
    canonical = json.dumps(inputs, ensure_ascii=False, sort_keys=True,
                           separators=(",", ":"), allow_nan=False).encode("utf-8")
    return hashlib.sha256(canonical).hexdigest()


def inventory(data):
    validate(data)
    primary, supporting, by_clause, by_test = (defaultdict(list) for _ in range(4))
    direct_tests, control_tests = set(), set()
    entries = data["ledger"]["requirements"]
    assessments = {e["clause"]: e for e in data["assessments"]["assessments"]}
    for name, test in data["tests"].items():
        primary[test["primary_clause"]].append(name)
        for clause in test["references"][1:]:
            supporting[clause].append(name)
    for entry in entries:
        by_clause[entry["clause"]].append(entry["id"])
        for link in entry["test_links"]:
            by_test[link["test"]].append({"requirement": entry["id"], "role": link["role"]})
            (direct_tests if link["role"] == "direct" else control_tests).add(link["test"])
    scope = data["scope"]
    clause_records = []
    for clause in data["clauses"]:
        chapter = clause.split(".")[0]
        disposition = ("candidate" if chapter in scope["candidate_roots"] else
                       "context" if chapter in scope["context_roots"] else "deferred")
        clause_records.append({"clause": clause, "scope": disposition,
                               "decomposition": ("partial" if by_clause[clause] else
                                                 "assessed" if clause in assessments else
                                                 "unassessed"),
                               "assessment": assessments.get(clause),
                               "primary_tests": sorted(primary[clause]),
                               "supporting_tests": sorted(supporting[clause]),
                               "requirement_ids": sorted(by_clause[clause])})
    candidates = [r for r in clause_records if r["scope"] == "candidate"]
    target = scope["legacy_clause_target"]
    candidate_focus = Counter("zero" if not r["primary_tests"] else
                              "below_target" if len(r["primary_tests"]) < target else
                              "at_least_target" for r in candidates)
    scope_counts = Counter(r["scope"] for r in clause_records)
    reviews = Counter(e["review"]["status"] for e in entries)
    summary = {"tests": len(data["tests"]), "clause_identifiers": len(clause_records),
               "scope_identifiers": {s: scope_counts[s] for s in ("candidate", "context", "deferred")},
               "primary_focus_identifiers": sum(bool(v) for v in primary.values()),
               "referenced_identifiers": sum(bool(primary[c] or supporting[c])
                                             for c in data["clauses"]),
               "legacy_clause_target": target,
               "candidate_primary_focus": {s: candidate_focus[s] for s in
                                           ("zero", "below_target", "at_least_target")},
               "draft_requirements": len(entries),
               "identifier_assessments": len(assessments),
               "assessment_classification": dict(Counter(e["classification"]
                                                          for e in assessments.values())),
               "assessment_review": dict(Counter(e["review"]["status"]
                                                 for e in assessments.values())),
               "requirements_with_direct_tests": sum(any(l["role"] == "direct"
                                                         for l in e["test_links"]) for e in entries),
               "requirements_without_direct_tests": sum(not any(l["role"] == "direct"
                                                                 for l in e["test_links"])
                                                        for e in entries),
               "requirement_review": {s: reviews[s] for s in ("ai", "human", "unreviewed")},
               "tests_with_direct_links": len(direct_tests),
               "tests_with_control_links": len(control_tests),
               "tests_without_requirement_links": len(data["tests"].keys() - by_test.keys())}
    roots = {}
    for root in dict.fromkeys(c.split(".")[0] for c in data["clauses"]):
        clauses = [c for c in clause_records if c["clause"].split(".")[0] == root]
        obligations = [e for e in entries if e["clause"].split(".")[0] == root]
        tests = [name for name, t in data["tests"].items()
                 if t["primary_clause"].split(".")[0] == root]
        roots[root] = {
            "scope": clauses[0]["scope"],
            "clause_identifiers": len(clauses),
            "partial_identifiers": sum(c["decomposition"] == "partial" for c in clauses),
            "assessed_identifiers": sum(c["decomposition"] == "assessed" for c in clauses),
            "unassessed_identifiers": sum(c["decomposition"] == "unassessed" for c in clauses),
            "draft_requirements": len(obligations),
            "requirements_with_direct_tests": sum(any(l["role"] == "direct"
                                                      for l in e["test_links"])
                                                 for e in obligations),
            "requirements_without_direct_tests": sum(not any(l["role"] == "direct"
                                                              for l in e["test_links"])
                                                    for e in obligations),
            "primary_focus_tests": len(tests),
            "primary_focus_tests_without_requirement_links": sum(not by_test[t] for t in tests),
        }
    return {"schema_version": 2, "standard": STANDARD, "scope_status": "proposed",
            "normative_inventory_complete": False, "approved_denominator": None,
            "coverage_percentage": None, "catalog_sha256": data["catalog_sha256"],
            "ledger_inputs_sha256": ledger_digest(data),
            "summary": summary, "roots": roots, "clauses": clause_records,
            "tests": {name: {**record, "requirement_links": sorted(by_test[name],
                                                                      key=lambda x: x["requirement"])}
                      for name, record in data["tests"].items()}}


def backlog(data, root=None):
    """Unmapped work items, never a list of established conformance gaps."""
    report = inventory(data)
    require(root is None or root in report["roots"], f"unknown catalog root {root}")

    def selected(clause):
        return root is None or clause.split(".")[0] == root

    obligations = [e for e in data["ledger"]["requirements"] if selected(e["clause"])]
    tests = {n: t for n, t in report["tests"].items() if selected(t["primary_clause"])}
    unlinked = [e for e in obligations if not any(l["role"] == "direct" for l in e["test_links"])]
    unmapped = [{"test": n, **t} for n, t in tests.items() if not t["requirement_links"]]
    unassessed = [c["clause"] for c in report["clauses"]
                  if selected(c["clause"]) and c["decomposition"] == "unassessed"]
    assessments = [c["assessment"] for c in report["clauses"]
                   if selected(c["clause"]) and c["assessment"] is not None]
    result = {key: report[key] for key in ("schema_version", "standard", "scope_status",
              "normative_inventory_complete", "approved_denominator", "coverage_percentage",
              "catalog_sha256", "ledger_inputs_sha256")}
    result.update(selection={"root": root},
                  roots={r: values for r, values in report["roots"].items()
                         if root is None or r == root},
                  summary={"draft_requirements": len(obligations),
                           "requirements_without_direct_tests": len(unlinked),
                           "primary_focus_tests": len(tests),
                           "tests_without_requirement_links": len(unmapped),
                           "identifier_assessments": len(assessments),
                           "unassessed_identifiers": len(unassessed)},
                  requirements_without_direct_tests=unlinked,
                  tests_without_requirement_links=unmapped,
                  identifier_assessments=assessments,
                  unassessed_identifiers=unassessed)
    return result


def sync_proposal(data):
    """Refresh unlinked inventory; preserve linked snapshots until reviewed."""
    validate(data, check_index=False)
    linked = {link["test"] for entry in data["ledger"]["requirements"]
              for link in entry["test_links"]}
    old = data["index"]["tests"]
    tests = {name: old[name] if name in linked and name in old else snapshot_for(record)
             for name, record in data["tests"].items()}
    return {"schema_version": 1, "standard": STANDARD, "tests": tests}


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("check", "inventory", "backlog", "sync"))
    parser.add_argument("--json", type=Path, help="write a generated inventory or backlog")
    parser.add_argument("--output", type=Path, help="write a test-index proposal (sync only)")
    parser.add_argument("--root", help="limit backlog to one catalog root, e.g. 5 or E")
    parser.add_argument("--lang", choices=("en", "ja"), default="en")
    args = parser.parse_args(argv)
    if args.command == "sync":
        if args.output is None or args.json is not None:
            parser.error("sync requires --output and does not accept --json")
    elif args.output is not None or (args.command == "check" and args.json is not None):
        parser.error("--output is for sync; --json is for inventory or backlog")
    if args.root is not None and args.command != "backlog":
        parser.error("--root is for backlog only")
    destination = args.output or args.json
    if destination and destination.resolve() in {(ROOT / "coverage" / n).resolve() for n in
                                                 ("scope.json", "requirements.json",
                                                  "assessments.json", "test_index.json")}:
        parser.error("generated output cannot overwrite ledger inputs; use a separate path")
    try:
        data = load()
        if args.command == "sync":
            write_json(args.output, sync_proposal(data))
            print("Wrote proposal; linked snapshots remain unchanged pending reassessment."
                  if args.lang == "en" else "案を出力しました。対応付け済みの指紋は再照合まで保持します。")
            return 0
        if args.command == "backlog":
            result = backlog(data, args.root)
            if args.json:
                write_json(args.json, result)
            s = result["summary"]
            print(f"Identifier assessments: {s['identifier_assessments']}" if args.lang == "en"
                  else f"条項番号の分類：{s['identifier_assessments']}件")
            selection = args.root or ("all" if args.lang == "en" else "全体")
            if args.lang == "en":
                print(f"Backlog ({selection}): {s['requirements_without_direct_tests']} "
                      f"requirements without direct tests; {s['tests_without_requirement_links']} "
                      f"tests without requirement links; {s['unassessed_identifiers']} "
                      "unassessed identifiers")
                print("Review work items only; scope and denominator remain unapproved.")
            else:
                print(f"未整理項目（{selection}）：直接の対応がない要求"
                      f"{s['requirements_without_direct_tests']}件・要求未対応のテスト"
                      f"{s['tests_without_requirement_links']}件・未評価の条項番号"
                      f"{s['unassessed_identifiers']}件")
                print("レビュー作業の一覧です。範囲と分母は未承認のままです。")
            return 0
        result = inventory(data)
        if args.json:
            write_json(args.json, result)
        s = result["summary"]
        print(f"Identifier assessments: {s['identifier_assessments']}" if args.lang == "en"
              else f"条項番号の分類：{s['identifier_assessments']}件")
        if args.lang == "en":
            print(f"{s['tests']} tests; {s['clause_identifiers']} clause identifiers; "
                  f"{s['draft_requirements']} draft requirements")
            print(f"Direct links: {s['requirements_with_direct_tests']} requirements, "
                  f"{s['tests_with_direct_links']} tests; "
                  f"{s['tests_without_requirement_links']} tests have no requirement links")
            print(f"Candidate primary-focus census (target {s['legacy_clause_target']}): "
                  f"{s['candidate_primary_focus']}")
            print("Scope is proposed; decomposition is incomplete; denominator and percentage unset.")
        else:
            print(f"テスト{s['tests']}件・条項番号{s['clause_identifiers']}件・要求案"
                  f"{s['draft_requirements']}件")
            print(f"直接の対応：要求{s['requirements_with_direct_tests']}件・"
                  f"テスト{s['tests_with_direct_links']}件。要求との対応がないテスト"
                  f"{s['tests_without_requirement_links']}件")
            print(f"対象候補の主引用の棚卸し（目標{s['legacy_clause_target']}件）："
                  f"{s['candidate_primary_focus']}")
            print("範囲は提案・要求分解は未完です。承認済み分母とカバレッジ率は未設定です。")
        return 0
    except (LedgerError, OSError, ValueError, KeyError, TypeError) as exc:
        print(f"requirements: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
