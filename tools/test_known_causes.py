"""Checks of tools/known_causes.py on a small fixture repository."""

import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import known_causes
import suite_results

REVIEW = {"status": "ai", "reviewer": None, "reviewed_at": None}


def text(en="Fixture note.", ja="検査用の説明。"):
    return {"en": en, "ja": ja}


class KnownCauses(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name).resolve()
        for module in (known_causes, suite_results):
            patch = mock.patch.object(module, "ROOT", self.root)
            patch.start()
            self.addCleanup(patch.stop)
        (self.root / "tools").mkdir()
        (self.root / "coverage").mkdir()
        (self.root / "tools/clauses_1800_2.txt").write_text("# fixture\n5\n5.1\n5.2\n6.1\n")
        (self.root / "third_party/uvm/9.9/src/base").mkdir(parents=True)
        (self.root / "third_party/uvm.lock").write_text(json.dumps({"version": "9.9"}))
        (self.root / "third_party/uvm/9.9/src/base/fixture.svh").write_text(
            "virtual class fixture_base;\nendclass\n")
        self.make("u05/test_tagged", "spec verilator@5.052")
        self.make("u05/test_runtime", "spec")
        self.make("u05/test_illegal", "spec", extra=":should_fail_because: fixture\n")
        self.make("u06/test_hdl", "spec", extra=":uvm_hdl_backend: vpi\n:uvm_dpi: yes\n")
        self.make("u06/test_fourstate", "spec", fourstate="yes")
        self.data = {
            "schema_version": 1, "standard": "1800.2-2020", "library": "9.9",
            "simulator": "verilator@5.052", "status": "partial",
            "reproducers": {"fixture-repro": {
                "clauses_1800_2023": ["8.21"],
                "source": ["module fixture_repro;", "endmodule"],
                "conforming": "rejects", "verilator": "accepts",
                "explanation": text()}},
            "causes": [
                self.entry("u05/test_illegal", "accepted-illegal", "simulator",
                           {"reproducer": "fixture-repro"}),
                self.entry("u05/test_runtime", "runtime", "library",
                           {"clauses": ["5.1"],
                            "library": [{"file": "src/base/fixture.svh",
                                         "text": "virtual class fixture_base;"}]}),
                self.entry("u06/test_hdl", "build", "condition", {}, condition="hdl"),
            ]}

    def make(self, name, oracle, *, fourstate="no", extra=""):
        path = self.root / "tests" / (name + ".sv")
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(f"/*\n:oracle: {oracle}\n:fourstate: {fourstate}\n{extra}*/\n"
                        f"module {path.stem}; endmodule\n")
        return path

    def entry(self, name, kind, cause, evidence, *, condition=None):
        path = self.root / "tests" / (name + ".sv")
        entry = {"test": name, "inputs_sha256": suite_results.input_digest(path), "kind": kind,
                 "cause": cause, "evidence": evidence,
                 "note": None if cause == "unassigned" else text(), "review": dict(REVIEW)}
        if condition:
            entry["condition"] = condition
        return entry

    def validate(self, data):
        known_causes.validate(data, self.root)

    def rejects(self, data, message):
        with self.assertRaisesRegex(known_causes.CauseError, message):
            self.validate(data)

    def test_a_complete_record_is_accepted(self):
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        self.validate(data)

    def test_status_follows_unassigned_entries(self):
        self.rejects(self.data, "status must be partial")
        data = copy.deepcopy(self.data)
        data["causes"][1] = self.entry("u05/test_runtime", "runtime", "unassigned", {})
        self.validate(data)
        data["status"] = "complete"
        self.rejects(data, "status must be partial")

    def test_every_known_difference_needs_one_entry(self):
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        del data["causes"][1]
        self.rejects(data, "1 known differences have no entry")
        data = copy.deepcopy(self.data)
        data["causes"].insert(1, copy.deepcopy(data["causes"][1]))
        self.rejects(data, "sorted by test, without repeats")

    def test_tagged_and_four_state_tests_have_no_entry(self):
        for name in ("u05/test_tagged", "u06/test_fourstate"):
            data = copy.deepcopy(self.data)
            data["status"] = "complete"
            data["causes"].append(self.entry(name, "runtime", "library",
                                             data["causes"][1]["evidence"]))
            data["causes"].sort(key=lambda e: e["test"])
            self.rejects(data, "four-state or recorded with verilator@5.052")

    def test_a_changed_input_needs_a_new_diagnosis(self):
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        path = self.root / "tests/u05/test_runtime.sv"
        path.write_text(path.read_text() + "// changed\n")
        self.rejects(data, "inputs changed after the diagnosis")

    def test_library_evidence_must_be_in_the_pinned_library(self):
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        data["causes"][1]["evidence"]["library"][0]["text"] = "class missing;"
        self.rejects(data, "does not contain")
        data["causes"][1]["evidence"]["library"][0] = {"file": "src/base/none.svh", "text": "x"}
        self.rejects(data, "not a file of the pinned library")
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        data["causes"][1]["evidence"]["clauses"] = ["9.9"]
        self.rejects(data, "is not an IEEE 1800.2-2020 clause")

    def test_an_interpretation_has_exactly_two_readings(self):
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        data["causes"][1]["cause"] = "interpretation"
        data["causes"][1]["evidence"] = {"clauses": ["5.2"], "readings": [text()]}
        self.rejects(data, "the test's reading and one other")
        data["causes"][1]["evidence"]["readings"].append(text())
        self.validate(data)

    def test_simulator_evidence_names_a_used_reproducer(self):
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        data["causes"][0]["evidence"]["reproducer"] = "other"
        self.rejects(data, "reproducer 'other' is not defined")
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        data["reproducers"]["spare-repro"] = copy.deepcopy(data["reproducers"]["fixture-repro"])
        data["reproducers"]["spare-repro"]["source"] = ["module spare_repro;", "endmodule"]
        self.rejects(data, "reproducers not used by any entry: spare-repro")

    def test_a_reproducer_is_one_module_without_uvm(self):
        for source, message in ((["module other;", "endmodule"], "one module named"),
                                (["import uvm_pkg::*;", "module fixture_repro;", "endmodule"],
                                 "must not use UVM")):
            data = copy.deepcopy(self.data)
            data["status"] = "complete"
            data["reproducers"]["fixture-repro"]["source"] = source
            self.rejects(data, message)
        data = copy.deepcopy(self.data)
        data["reproducers"]["fixture-repro"]["verilator"] = "rejects"
        self.rejects(data, "must be different values")

    def test_conditions_follow_the_test_header(self):
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        del data["causes"][2]["condition"]
        self.rejects(data, "condition must be hdl")
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        data["causes"][1].update(cause="condition", evidence={})
        self.rejects(data, "the test selects no DPI condition|only a test that selects")

    def test_kinds_follow_should_fail_because(self):
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        data["causes"][1]["kind"] = "accepted-illegal"
        self.rejects(data, "does not fit :should_fail_because:")
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        data["causes"][0]["kind"] = "runtime"
        self.rejects(data, "does not fit :should_fail_because:")

    def test_controls_must_be_tagged_tests(self):
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        data["causes"][1]["evidence"]["controls"] = ["u05/test_tagged"]
        self.validate(data)
        data["causes"][1]["evidence"]["controls"] = ["u05/test_illegal"]
        self.rejects(data, "is not recorded with verilator@5.052")

    def test_human_review_needs_a_reviewer_and_date(self):
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        data["causes"][1]["review"] = {"status": "human", "reviewer": None, "reviewed_at": None}
        self.rejects(data, "identified reviewer")
        data["causes"][1]["review"] = {"status": "human", "reviewer": "fixture",
                                       "reviewed_at": "2026-11-09"}
        self.validate(data)

    def test_results_must_match_the_entries(self):
        data = copy.deepcopy(self.data)
        data["status"] = "complete"
        self.validate(data)
        records = {e["test"]: {"status": "known", "inputs_sha256": e["inputs_sha256"],
                               "reason": reason}
                   for e, reason in zip(data["causes"],
                                        ("the design was accepted, but it is illegal",
                                         "seed 1: output differs: line 1 is 'a', expected 'b'",
                                         "build failed: linker command failed"))}
        records["u05/test_tagged"] = {"status": "pass", "inputs_sha256": "0" * 64}
        path = self.root / "results.json"

        def write(tests):
            path.write_text(json.dumps({"simulator": "verilator", "name": "Verilator",
                                        "version": "Verilator 5.052", "tests": tests}))
        write(records)
        self.assertEqual(known_causes.check_results(data, path), 3)
        changed = copy.deepcopy(records)
        changed["u05/test_runtime"]["reason"] = "build failed: x"
        write(changed)
        with self.assertRaisesRegex(known_causes.CauseError, "not a runtime difference"):
            known_causes.check_results(data, path)
        changed = copy.deepcopy(records)
        changed["u06/test_hdl"]["status"] = "pass"
        write(changed)
        with self.assertRaisesRegex(known_causes.CauseError, "1 entries that are not known"):
            known_causes.check_results(data, path)

    def test_summary_separates_the_kirimasim_targets(self):
        data = copy.deepcopy(self.data)
        data["causes"].append(self.entry("u05/test_tagged", "runtime", "unassigned", {}))
        s = known_causes.summary(data, self.root)
        self.assertEqual((s["tests"], s["verilator_tagged"], s["known"],
                          s["four_state_without_verilator_record"]), (5, 1, 4, 1))
        self.assertEqual(s["kirimasim_targets"], {"measurable": 3,
                                                  "blocked_by_pinned_library": 1,
                                                  "not_yet_classified": 1})
        self.assertEqual(s["with_condition"], 1)

    def test_candidates_list_interpretation_then_library_then_simulator(self):
        data = copy.deepcopy(self.data)
        data["causes"][2].update(cause="interpretation",
                                 evidence={"clauses": ["5.1"], "readings": [text(), text()]})
        rows = known_causes.candidates(data)
        self.assertEqual([(r["test"], r["cause"]) for r in rows],
                         [("u06/test_hdl", "interpretation"), ("u05/test_runtime", "library"),
                          ("u05/test_illegal", "simulator")])
        data["causes"][1]["review"] = {"status": "human", "reviewer": "fixture",
                                       "reviewed_at": "2026-11-09"}
        self.assertEqual(len(known_causes.candidates(data)), 2)


if __name__ == "__main__":
    unittest.main()
