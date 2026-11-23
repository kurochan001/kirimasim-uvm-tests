"""Checks the report declaration file and its clauses."""

import contextlib
import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import uvm_reports

TEST = "u05/test_sample"
HEADER = ("/*\n:type: simulation\n"
          ":lrm: 1800.2-2020 5.7.2.2 5.7.2.3 1800-2023 6.21\n*/\n"
          "module test_sample; endmodule\n")


class ReportsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        test = self.root / "tests" / (TEST + ".sv")
        test.parent.mkdir(parents=True)
        test.write_text(HEADER)
        patcher = mock.patch.object(uvm_reports, "ROOT", self.root)
        patcher.start()
        self.addCleanup(patcher.stop)

    def data(self, entry=None):
        return {"schema": 1, "tests": {TEST: entry or {
            "error": True, "fatal": False, "basis": ["1800.2-2020 5.7.2.2"]}}}

    def test_valid_entry(self):
        self.assertEqual(uvm_reports.problems(self.data()), [])

    def test_unknown_test(self):
        data = self.data()
        data["tests"]["u05/test_missing"] = data["tests"].pop(TEST)
        self.assertIn("no such test", "\n".join(uvm_reports.problems(data)))

    def test_neither_severity_is_rejected(self):
        data = self.data({"error": False, "fatal": False,
                          "basis": ["1800.2-2020 5.7.2.2"]})
        self.assertIn("permits neither", "\n".join(uvm_reports.problems(data)))

    def test_basis_must_be_in_lrm(self):
        data = self.data({"error": True, "fatal": False,
                          "basis": ["1800.2-2020 9.9.9"]})
        self.assertIn("not in :lrm:", "\n".join(uvm_reports.problems(data)))

    def test_basis_needs_a_standard(self):
        data = self.data({"error": True, "fatal": False, "basis": ["5.7.2.2"]})
        self.assertIn("not '<standard> <clause>'", "\n".join(uvm_reports.problems(data)))

    def test_letter_prefixed_clause(self):
        name = "uF/test_sample"
        (self.root / "tests" / "uF").mkdir()
        (self.root / "tests" / "uF" / "test_sample.sv").write_text(
            "/*\n:type: simulation\n:lrm: 1800.2-2020 F.7.2.1\n*/\n"
            "module test_sample; endmodule\n")
        data = {"schema": 1, "tests": {name: {
            "error": False, "fatal": True, "basis": ["1800.2-2020 F.7.2.1"]}}}
        self.assertEqual(uvm_reports.problems(data), [])

    def test_switching_back_to_the_first_standard_keeps_the_citations_separate(self):
        cited = uvm_reports.lrm({"lrm": "1800.2-2020 5.7.2.2 1800-2023 6.21 1800.2-2020 5.7.2.3"})
        self.assertEqual(cited, {"1800.2-2020": {"5.7.2.2", "5.7.2.3"}, "1800-2023": {"6.21"}})

    def test_booleans_are_required(self):
        data = self.data({"error": 1, "fatal": False,
                          "basis": ["1800.2-2020 5.7.2.2"]})
        self.assertIn("must be booleans", "\n".join(uvm_reports.problems(data)))

    def test_tests_are_sorted(self):
        second = "u05/test_second"
        (self.root / "tests" / "u05" / "test_second.sv").write_text(HEADER)
        data = {"schema": 1, "tests": {
            second: {"error": True, "fatal": False, "basis": ["1800.2-2020 5.7.2.2"]},
            TEST: {"error": True, "fatal": False, "basis": ["1800.2-2020 5.7.2.2"]}}}
        self.assertIn("not in sorted order", "\n".join(uvm_reports.problems(data)))

    def test_duplicate_key_is_rejected(self):
        path = self.root / "duplicate.json"
        path.write_text('{"schema": 1, "tests": {}, "tests": {}}')
        with self.assertRaises(ValueError):
            uvm_reports.load(path)

    def test_each_standard_keeps_only_its_own_clauses(self):
        # The sample cites 5.7.2.2 and 5.7.2.3 under 1800.2-2020, and 6.21
        # under 1800-2023; a basis must not borrow a clause across standards.
        for bad in ("1800-2023 5.7.2.2", "1800.2-2020 6.21"):
            data = self.data({"error": True, "fatal": False, "basis": [bad]})
            self.assertIn("not in :lrm:", "\n".join(uvm_reports.problems(data)))
        both = self.root / "tests/u05/test_two_standards.sv"
        both.write_text("/*\n:type: simulation\n"
                        ":lrm: 1800.2-2020 5.7.2.2 1800-2023 6.21\n*/\n"
                        "module test_two_standards; endmodule\n")
        data = {"schema": 1, "tests": {"u05/test_two_standards": {
            "error": True, "fatal": False,
            "basis": ["1800.2-2020 5.7.2.2", "1800-2023 6.21"]}}}
        self.assertEqual(uvm_reports.problems(data), [])

    def test_summary_counts_permissions(self):
        text = uvm_reports.summary({"tests": {
            "a": {"error": True, "fatal": False},
            "b": {"error": True, "fatal": True},
            "c": {"error": False, "fatal": True}}})
        self.assertIn("3 tests", text)
        self.assertIn("both 1", text)
        self.assertIn("error-only 1", text)
        self.assertIn("fatal-only 1", text)

    def test_the_command_names_a_file_it_cannot_read_or_parse(self):
        stream = io.StringIO()
        with contextlib.redirect_stderr(stream):
            self.assertEqual(uvm_reports.main(
                ["check", "--file", str(self.root / "absent.json")]), 1)
            self.assertIn("absent.json", stream.getvalue())
        broken = self.root / "broken.json"
        broken.write_text("{oops")
        stream = io.StringIO()
        with contextlib.redirect_stderr(stream):
            self.assertEqual(uvm_reports.main(["check", "--file", str(broken)]), 1)
        self.assertIn("broken.json", stream.getvalue())

    def test_the_command_checks_the_file_and_prints_the_summary(self):
        good = self.root / "reports.json"
        good.write_text(json.dumps({"schema": 1, "tests": {TEST: {
            "error": True, "fatal": False, "basis": ["1800.2-2020 5.7.2.2"]}}}))
        stream = io.StringIO()
        with contextlib.redirect_stdout(stream):
            self.assertEqual(uvm_reports.main(["check", "--file", str(good)]), 0)
        self.assertIn("uvm_reports: 1 tests", stream.getvalue())
        stream = io.StringIO()
        with contextlib.redirect_stdout(stream):
            self.assertEqual(uvm_reports.main(["summary", "--file", str(good)]), 0)
        self.assertNotIn("uvm_reports:", stream.getvalue())
        bad = self.root / "bad.json"
        bad.write_text(json.dumps({"schema": 2, "tests": {}}))
        stream = io.StringIO()
        with contextlib.redirect_stdout(stream):
            self.assertEqual(uvm_reports.main(["check", "--file", str(bad)]), 1)
        self.assertIn("schema is 2", stream.getvalue())

    def test_summary_refuses_an_invalid_declaration(self):
        bad = self.root / "bad.json"
        bad.write_text(json.dumps({"schema": 1, "tests": {TEST: None}}))
        with contextlib.redirect_stdout(io.StringIO()) as out:
            self.assertEqual(uvm_reports.main(["summary", "--file", str(bad)]), 1)
        self.assertIn("entry is not an object", out.getvalue())


if __name__ == "__main__":
    unittest.main()
