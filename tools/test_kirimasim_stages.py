"""Checks of tools/kirimasim_stages.py on a small fixture repository, and of the
markers of the real record on short snippets."""

import contextlib
import copy
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import kirimasim_stages
import suite_results

REAL = kirimasim_stages.load()


def text(en="Fixture text.", ja="検査用の文。"):
    return {"en": en, "ja": ja}


class Fixture(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name).resolve()
        for module in (kirimasim_stages, suite_results):
            patch = mock.patch.object(module, "ROOT", self.root)
            patch.start()
            self.addCleanup(patch.stop)
        (self.root / "coverage").mkdir()
        (self.root / "third_party").mkdir()
        (self.root / "third_party/uvm.lock").write_text(json.dumps({"version": "9.9"}))
        self.make("u01/test_s0", "  initial $display(\"UT: %0d\", uvm_pkg::UVM_LOW);\n")
        self.make("u05/test_s1", "  initial run_test(\"t\");\n")
        self.make("u08/test_s2", "  initial o = thing::type_id::create(\"o\");\n")
        self.make("uC/test_s3", "  initial uvm_config_db#(int)::set(null, \"*\", \"x\", 1);\n")
        self.make("u14/test_s4", "  uvm_sequence#(item) s;\n")
        self.make("u12/test_s5", "  uvm_analysis_port#(int) p;\n")
        self.make("u18/test_s6", "  uvm_reg_block b;\n")
        self.make("u12/test_untagged", "  uvm_analysis_port#(int) p;\n", oracle="spec")
        self.make("u05/test_illegal", "  initial run_test(\"t\");\n", kind="elaboration")
        self.stages = [dict(stage=n, name=text(), description=text(), markers=[], short=[])
                       for n in range(7)]
        for n, marker in ((2, r"::type_id\b"), (3, r"\buvm_config_db\b"),
                          (4, r"\buvm_sequence\b"), (5, r"\buvm_analysis_port\b"),
                          (6, r"\buvm_reg(?![a-z_]*_t\b)(?:_\w+)?\b")):
            self.stages[n]["markers"] = [marker]
        for n, name in enumerate(("u01/test_s0", "u05/test_s1", "u08/test_s2", "uC/test_s3",
                                  "u14/test_s4", "u12/test_s5", "u18/test_s6")):
            self.stages[n]["short"] = [name]
        self.data = {
            "schema_version": 1, "standard": "1800.2-2020", "library": "9.9",
            "simulator": "verilator@5.052", "purpose": text(), "stages": self.stages,
            "overrides": {"u01/test_s0": {"stage": 0, "reason": text()}},
            "tests": {}}
        self.data["tests"] = self.expected_tests()

    def expected_tests(self):
        return {"u01/test_s0": 0, "u05/test_illegal": 1, "u05/test_s1": 1, "u08/test_s2": 2,
                "u12/test_s5": 5, "u12/test_untagged": 5, "u14/test_s4": 4, "u18/test_s6": 6,
                "uC/test_s3": 3}

    def make(self, name, body, *, oracle="spec verilator@5.052", kind="simulation", extra=""):
        path = self.root / "tests" / (name + ".sv")
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(f"/*\n:type: {kind}\n:oracle: {oracle}\n{extra}*/\n"
                        f"module {path.stem};\n{body}endmodule\n")
        return path

    def validate(self, data):
        return kirimasim_stages.validate(data, self.root)

    def rejects(self, data, message):
        with self.assertRaisesRegex(kirimasim_stages.StageError, message):
            self.validate(data)

    def write(self, data):
        (self.root / "coverage/kirimasim_stages.json").write_text(json.dumps(data))


class Stages(Fixture):
    def test_a_matching_record_is_accepted(self):
        self.assertEqual(self.validate(copy.deepcopy(self.data)), self.expected_tests())

    def test_markers_ignore_comments_and_strings(self):
        self.make("u05/test_s1", "  // uvm_reg_block b;\n  /* uvm_sequence s; */\n"
                                 "  initial $display(\"uvm_config_db ::type_id\");\n")
        self.validate(copy.deepcopy(self.data))

    def test_the_highest_marker_and_collected_files_set_the_stage(self):
        helper = self.root / "tests/u05/helper/model.svh"
        helper.parent.mkdir()
        helper.write_text("class model; uvm_reg r; endclass\n")
        self.make("u05/test_s1", "  `include \"model.svh\"\n  uvm_sequence#(item) s;\n",
                  extra=":files: helper/model.svh\n")
        data = copy.deepcopy(self.data)
        self.rejects(data, "1 entries differ")
        data["tests"]["u05/test_s1"] = 6
        data["stages"][1]["short"] = ["u05/test_illegal"]
        self.rejects(data, "not a simulation test")
        data["stages"][1]["short"] = []
        self.rejects(data, "the short set needs 1 to 10 tests")

    def test_typedefs_of_a_later_stage_do_not_place_a_test(self):
        self.make("u05/test_s1", "  uvm_reg_data_t value;\n  initial run_test(\"t\");\n")
        self.validate(copy.deepcopy(self.data))

    def test_every_test_needs_exactly_one_current_entry(self):
        data = copy.deepcopy(self.data)
        del data["tests"]["u05/test_s1"]
        self.rejects(data, "1 tests have no stage")
        data = copy.deepcopy(self.data)
        data["tests"]["u05/test_gone"] = 1
        data["tests"] = dict(sorted(data["tests"].items()))
        self.rejects(data, "1 entries name no test")
        data = copy.deepcopy(self.data)
        data["tests"]["u05/test_s1"] = 2
        self.rejects(data, "1 entries differ from the markers and overrides")
        data = copy.deepcopy(self.data)
        data["tests"] = dict(reversed(list(data["tests"].items())))
        self.rejects(data, "must be sorted")

    def test_overrides_need_a_reason_and_a_different_stage(self):
        data = copy.deepcopy(self.data)
        data["overrides"]["u05/test_s1"] = {"stage": 1, "reason": text()}
        self.rejects(data, "the markers already give stage 1")
        data = copy.deepcopy(self.data)
        data["overrides"]["u05/test_none"] = {"stage": 0, "reason": text()}
        self.rejects(data, "no such test")
        data = copy.deepcopy(self.data)
        data["overrides"]["u01/test_s0"]["reason"] = {"en": "Only English."}
        self.rejects(data, "expected fields en, ja")
        data = copy.deepcopy(self.data)
        data["overrides"]["u01/test_s0"]["stage"] = 7
        self.rejects(data, "stage must be 0 to 6")

    def test_short_sets_hold_tagged_tests_of_their_own_stage(self):
        data = copy.deepcopy(self.data)
        data["stages"][5]["short"].append("u12/test_untagged")
        self.rejects(data, "not recorded with verilator@5.052")
        data = copy.deepcopy(self.data)
        data["stages"][4]["short"].append("u12/test_s5")
        self.rejects(data, "its stage is 5")
        data = copy.deepcopy(self.data)
        data["stages"][6]["short"].append("u12/test_s5")
        data["stages"][5]["short"].append("u12/test_s5")
        self.rejects(data, "listed twice")
        data = copy.deepcopy(self.data)
        data["stages"][3]["short"].append("uC/test_none")
        self.rejects(data, "no such test")

    def test_a_stage_without_its_own_test_cannot_keep_a_short_set(self):
        data = copy.deepcopy(self.data)
        del data["overrides"]["u01/test_s0"]
        data["tests"]["u01/test_s0"] = 1
        self.rejects(data, "stage 0 short set: u01/test_s0: its stage is 1")
        data["stages"][0]["short"] = ["u05/test_s1"]
        self.rejects(data, "stage 0 short set: u05/test_s1: its stage is 1")

    def test_record_shape(self):
        data = copy.deepcopy(self.data)
        data["stages"][1]["markers"] = [r"\buvm_object\b"]
        self.rejects(data, "only stages 2 to 6 have markers")
        data = copy.deepcopy(self.data)
        data["stages"][2]["markers"] = ["("]
        self.rejects(data, "invalid marker")
        data = copy.deepcopy(self.data)
        data["stages"][3]["markers"] = []
        self.rejects(data, "needs at least one marker")
        data = copy.deepcopy(self.data)
        data["stages"] = data["stages"][:6]
        self.rejects(data, "stages 0 to 6 in order")
        data = copy.deepcopy(self.data)
        data["library"] = "1.0"
        self.rejects(data, "locked version 9.9")
        data = copy.deepcopy(self.data)
        data["extra"] = 1
        self.rejects(data, "expected fields")

    def test_update_rewrites_the_entries_and_reports_changes(self):
        data = copy.deepcopy(self.data)
        data["tests"] = {"u05/test_gone": 1, "u05/test_s1": 4}
        self.write(data)
        changes = kirimasim_stages.update(self.root)
        self.assertEqual(changes["removed"], ["u05/test_gone"])
        self.assertEqual(changes["changed"], ["u05/test_s1"])
        self.assertEqual(len(changes["added"]), len(self.expected_tests()) - 1)
        self.validate(kirimasim_stages.load(self.root))

    def test_summary_counts_current_records_by_stage(self):
        digest = suite_results.input_digest(self.root / "tests/u05/test_s1.sv")
        results = self.root / "results.json"
        results.write_text(json.dumps({"simulator": "kirimasim", "tests": {
            "u05/test_s1": {"status": "unsupported", "reason": "a construct",
                            "inputs_sha256": digest},
            "u05/test_illegal": {"status": "fail", "inputs_sha256": "0" * 64},
            "u12/test_s5": {"status": "pass"}}}))
        s = kirimasim_stages.summary(self.data, [results], self.root)
        self.assertEqual([row["tests"] for row in s["stages"]], [1, 2, 1, 1, 1, 2, 1])
        self.assertEqual(s["stages"][5]["verilator_tagged"], 1)
        by_stage = s["results"][0]["by_stage"]
        self.assertEqual(by_stage[1]["statuses"], {"changed": 1, "unsupported": 1})
        self.assertEqual(by_stage[1]["top_reason"], "a construct")
        self.assertEqual(by_stage[5]["statuses"], {"pass": 1, "unmeasured": 1})
        self.assertEqual(by_stage[0]["statuses"], {"unmeasured": 1})

    def test_short_prints_paths_for_the_runner(self):
        self.write(self.data)
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            self.assertEqual(kirimasim_stages.main(["short", "--upto", "1"]), 0)
        self.assertEqual(out.getvalue().split(), ["tests/u01/test_s0.sv", "tests/u05/test_s1.sv"])
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            self.assertEqual(kirimasim_stages.main(["short", "6"]), 0)
        self.assertEqual(out.getvalue().split(), ["tests/u18/test_s6.sv"])
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            kirimasim_stages.main(["short", "--upto", "1", "2"])

    def test_check_reports_a_mismatch_with_exit_status_1(self):
        data = copy.deepcopy(self.data)
        data["tests"]["u05/test_s1"] = 3
        self.write(data)
        err = io.StringIO()
        with contextlib.redirect_stderr(err):
            self.assertEqual(kirimasim_stages.main(["check"]), 1)
        self.assertIn("differ", err.getvalue())


class RealMarkers(unittest.TestCase):
    """The markers of coverage/kirimasim_stages.json on short snippets."""

    def stage(self, snippet):
        markers = kirimasim_stages.compiled_markers(REAL)
        return kirimasim_stages.rule_stage(
            kirimasim_stages.NOT_CODE.sub(" ", snippet), markers)

    def test_each_stage_has_a_typical_use(self):
        self.assertEqual(self.stage("class t extends uvm_test; endclass run_test(\"t\");"), 1)
        self.assertEqual(self.stage("o = item::type_id::create(\"o\");"), 2)
        self.assertEqual(self.stage("factory.set_type_override_by_name(\"a\", \"b\");"), 2)
        self.assertEqual(self.stage("uvm_config_db#(int)::get(this, \"\", \"n\", n);"), 3)
        self.assertEqual(self.stage("start_item(req); finish_item(req);"), 4)
        self.assertEqual(self.stage("`uvm_do_with(req, {data == 1;})"), 4)
        self.assertEqual(self.stage("uvm_tlm_fifo#(int) f;"), 5)
        self.assertEqual(self.stage("`uvm_analysis_imp_decl(_a)"), 5)
        self.assertEqual(self.stage("uvm_reg_field f; uvm_reg_map m;"), 6)
        self.assertEqual(self.stage("uvm_hdl_deposit(\"top.r\", 1);"), 6)

    def test_lookalikes_do_not_raise_the_stage(self):
        self.assertEqual(self.stage("`uvm_do_callbacks(t, cb, f())"), 1)
        self.assertEqual(self.stage("uvm_sequence_item item; uvm_sequence_state_enum s;"), 1)
        self.assertEqual(self.stage("uvm_reg_data_t d; uvm_reg_addr_t a;"), 1)
        self.assertEqual(self.stage("s = get_type_name();"), 1)
        self.assertEqual(self.stage("$display(\"uvm_reg_block\"); // uvm_tlm_fifo"), 1)

    def test_the_stage_zero_input_is_an_override(self):
        self.assertEqual(
            REAL["overrides"]["u01/test_uvm_pkg_import_only_reaches_package_items"]["stage"], 0)


if __name__ == "__main__":
    unittest.main()
