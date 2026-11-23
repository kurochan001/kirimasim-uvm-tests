"""Checks of tools/slang_elaborate.py that need no slang: the record's rules
and the judgment of an elaboration's output."""

import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import slang_elaborate
import suite_results

NOTE = {"en": "English.", "ja": "日本語。"}
ERROR = "tests/u05/{name}.sv:3:5: error: {text}\n"


class Frontend(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name).resolve()
        for module in (slang_elaborate, suite_results):
            patch = mock.patch.object(module, "ROOT", self.root)
            patch.start()
            self.addCleanup(patch.stop)
        (self.root / "coverage").mkdir()
        self.make("u05/test_clean", "spec verilator@5.054")
        self.make("u05/test_strict", "spec verilator@5.054")
        self.make("u05/test_unit", "spec verilator@5.054")
        self.make("u05/test_library", "spec")
        self.make("u05/test_runtime", "spec")
        self.make("u05/test_illegal", "spec verilator@5.054",
                  extra=":should_fail_because: fixture\n:expected_stderr_regex: (?i)abstract.*error"
                        "|error.*abstract\n")
        self.make("u05/test_accepted", "spec", extra=":should_fail_because: fixture\n"
                                                    ":expected_stderr_regex: x\n")
        causes = [{"test": "u05/test_accepted", "kind": "accepted-illegal", "cause": "library"},
                  {"test": "u05/test_library", "kind": "build", "cause": "library"},
                  {"test": "u05/test_runtime", "kind": "runtime", "cause": "interpretation"}]
        (self.root / "coverage/known_causes.json").write_text(json.dumps({"causes": causes}))
        self.data = {
            "schema_version": 1, "tool": "pyslang", "version": "12.1.0",
            "options": ["--std=1800-2023"], "purpose": NOTE,
            "tests": {
                "u05/test_accepted": {"reason": "accepted-illegal", "error": None, "note": NOTE},
                "u05/test_library": {"reason": "library", "error": "no member", "note": NOTE},
                "u05/test_runtime": {"reason": "library", "error": "bad assignment",
                                     "verilator_kind": "runtime", "note": NOTE},
                "u05/test_strict": {"reason": "warning-as-error", "error": "out of range",
                                    "clauses_1800_2023": ["7.4.6"], "note": NOTE},
                "u05/test_unit": {"reason": "single-unit", "error": "unknown macro",
                                  "clauses_1800_2023": ["3.12.1"], "note": NOTE}}}

    def make(self, name, oracle, *, extra=""):
        path = self.root / "tests" / (name + ".sv")
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(f"/*\n:oracle: {oracle}\n{extra}*/\nmodule {path.stem}; endmodule\n")
        return path

    def rejects(self, data, message):
        with self.assertRaisesRegex(slang_elaborate.FrontendError, message):
            slang_elaborate.validate(data, self.root)

    def judge(self, name, output, single=None):
        test = self.root / "tests" / (name + ".sv")
        return slang_elaborate.judge(name, test, self.data["tests"].get(name), output, single)

    def test_the_record_is_accepted(self):
        slang_elaborate.validate(self.data, self.root)
        self.assertEqual(slang_elaborate.summary(self.data)["verilator_builds_but_slang_rejects"],
                         ["u05/test_runtime"])
        (self.root / "coverage/slang_frontend.json").write_text(json.dumps(self.data))
        self.assertEqual(slang_elaborate.single_unit_tests(self.root), {"u05/test_unit"})

    def test_a_library_entry_needs_a_cause_and_its_kind(self):
        data = copy.deepcopy(self.data)
        data["tests"]["u05/test_clean"] = {"reason": "library", "error": "x", "note": NOTE}
        data["tests"] = dict(sorted(data["tests"].items()))
        self.rejects(data, "needs a library or interpretation entry")
        data = copy.deepcopy(self.data)
        del data["tests"]["u05/test_runtime"]["verilator_kind"]
        self.rejects(data, "verilator_kind must be runtime")
        data = copy.deepcopy(self.data)
        data["tests"]["u05/test_library"]["verilator_kind"] = "runtime"
        self.rejects(data, "Verilator also fails to build")

    def test_other_reasons_cite_the_clause_that_allows_the_code(self):
        data = copy.deepcopy(self.data)
        del data["tests"]["u05/test_strict"]["clauses_1800_2023"]
        self.rejects(data, "clauses_1800_2023 must name")
        data = copy.deepcopy(self.data)
        data["tests"]["u05/test_strict"]["reason"] = "accepted-illegal"
        self.rejects(data, "only an illegal design")
        data = copy.deepcopy(self.data)
        data["tests"]["u05/test_strict"]["note"] = {"en": "Only English."}
        self.rejects(data, "expected fields en, ja")
        data = copy.deepcopy(self.data)
        data["tests"]["u05/test_zz_none"] = data["tests"].pop("u05/test_unit")
        self.rejects(data, "no such test")

    def test_a_legal_test_has_an_error_only_when_it_is_listed(self):
        self.assertEqual(self.judge("u05/test_clean", ""), "")
        self.assertIn("slang reports an error: bad thing",
                      self.judge("u05/test_clean", ERROR.format(name="test_clean", text="bad thing")))
        listed = ERROR.format(name="test_strict", text="out of range")
        self.assertEqual(self.judge("u05/test_strict", listed), "")
        self.assertIn("no error now", self.judge("u05/test_strict", "warning: only\n"))
        self.assertIn("the first error is now: other",
                      self.judge("u05/test_strict", ERROR.format(name="test_strict", text="other")))

    def test_an_error_without_a_place_is_an_error(self):
        output = "error: 'test_typo' is not a valid top-level module\n"
        self.assertEqual(slang_elaborate.errors(output),
                         ["'test_typo' is not a valid top-level module"])
        self.assertIn("slang reports an error: 'test_typo'", self.judge("u05/test_clean", output))
        self.assertEqual(slang_elaborate.errors("tests/a.sv:1:2: warning: error: in a name\n"), [])

    def test_a_run_that_slang_did_not_finish_is_not_a_result(self):
        for code, text in ((1, "Traceback"), (-11, ""), (2, "no diagnostics")):
            done = mock.Mock(returncode=code, stdout=text, stderr="")
            with (mock.patch.object(slang_elaborate.subprocess, "run", return_value=done),
                  mock.patch.object(slang_elaborate, "command", return_value=[])):
                with self.assertRaises(slang_elaborate.FrontendError):
                    slang_elaborate.elaborate(self.root / "tests/u05/test_clean.sv", [])

    def test_a_single_unit_test_must_be_clean_in_one_unit(self):
        first = ERROR.format(name="test_unit", text="unknown macro")
        self.assertEqual(self.judge("u05/test_unit", first, ""), "")
        self.assertIn("an error remains with --single-unit", self.judge("u05/test_unit", first, first))

    def test_an_illegal_design_is_rejected_at_its_pattern_or_listed(self):
        good = ERROR.format(name="test_illegal", text="cannot create an abstract class")
        self.assertEqual(self.judge("u05/test_illegal", good), "")
        self.assertIn("no error matches",
                      self.judge("u05/test_illegal", ERROR.format(name="test_illegal", text="other")))
        self.assertIn("accepts the illegal design", self.judge("u05/test_illegal", ""))
        self.assertEqual(self.judge("u05/test_accepted", ""), "")
        self.assertIn("now rejects",
                      self.judge("u05/test_accepted", ERROR.format(name="test_accepted", text="x")))

    def test_check_runs_each_test_and_one_unit_where_needed(self):
        outputs = {"test_library": "no member", "test_runtime": "bad assignment",
                   "test_strict": "out of range", "test_unit": "unknown macro",
                   "test_illegal": "an abstract class"}
        calls = []

        def fake(test, options):
            calls.append((test.stem, tuple(options)))
            if "--single-unit" in options or test.stem not in outputs:
                return ""
            return ERROR.format(name=test.stem, text=outputs[test.stem])
        with mock.patch.object(slang_elaborate, "elaborate", side_effect=fake):
            problems, first = slang_elaborate.check(self.data, [], 1, self.root)
        self.assertEqual(problems, [])
        fixtures = list((self.root / "tests/u05").glob("test_*.sv"))
        self.assertEqual(first, {f"u05/{t.stem}": outputs.get(t.stem) for t in fixtures})
        expected = [(t.stem, ("--std=1800-2023",)) for t in fixtures]
        expected.append(("test_unit", ("--std=1800-2023", "--single-unit")))
        self.assertCountEqual(calls, expected)


if __name__ == "__main__":
    unittest.main()
