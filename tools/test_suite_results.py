"""Checks of the shared test metadata and the result JSON of tools/suite_results.py."""

import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import suite_results

HEADER = """/*
:name: {name}
:type: simulation
{fields}*/
module {name}; endmodule
"""


class SuiteResults(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        patch = mock.patch.object(suite_results, "ROOT", self.root)
        patch.start()
        self.addCleanup(patch.stop)
        self.dir = self.root / "tests/u05"
        self.dir.mkdir(parents=True)

    def make(self, name="test_a", fields="", files=None):
        test = self.dir / f"{name}.sv"
        test.write_text(HEADER.format(name=name, fields=fields))
        for rel, text in (files or {}).items():
            other = self.dir / rel
            other.parent.mkdir(parents=True, exist_ok=True)
            other.write_text(text)
        return test


class MetadataFields(SuiteResults):
    def test_files_keeps_the_declared_order_and_collects_include_dirs_once(self):
        test = self.make(fields=":files: helpers/h.svh lib/m.sv lib/m.sv lib/data.rsc\n"
                                 ":incdirs: extra\n",
                         files={"helpers/h.svh": "", "lib/m.sv": "", "lib/data.rsc": ""})
        sources, include_dirs = suite_results.files(test)
        # Sources are .sv and .v, in the order written; the directories of the
        # other files, then the named :incdirs:, are include directories, once.
        self.assertEqual([p.name for p in sources], ["m.sv", "m.sv"])
        self.assertEqual([d.name for d in include_dirs], ["helpers", "lib", "extra"])

    def test_incdirs_relative_to_the_test_follow_the_files_it_names(self):
        test = self.make(fields=":incdirs: lib/../lib helpers\n:defines: A=1 B\n")
        sources, include_dirs = suite_results.files(test)
        self.assertEqual(sources, [])
        self.assertEqual([d.name for d in include_dirs], ["lib", "helpers"])
        self.assertEqual(suite_results.defines(test), ["A=1", "B"])

    def test_the_runner_reads_exit_args_and_top_from_the_header(self):
        test = self.make(fields=":args: +plus +other\n:top_module: top_a\n")
        self.assertEqual(suite_results.run_args(test), ["+plus", "+other"])
        self.assertEqual(suite_results.top_module(test), "top_a")
        self.assertIsNone(suite_results.top_module(self.make(name="test_no_top")))


class ExpectedOutput(SuiteResults):
    def test_the_simulator_field_wins_and_a_field_of_another_never_substitutes(self):
        test = self.make(fields=":expected_stdout: generic\n"
                                 ":expected_stdout_ghost: only ghost\n")
        self.assertEqual(suite_results.expected_output(test), "generic\n")
        self.assertEqual(suite_results.expected_output(test, "verilator"), "generic\n")
        self.assertEqual(suite_results.expected_output(test, "ghost"), "only ghost\n")
        test = self.make(name="test_ghost_only", fields=":expected_stdout_ghost: ghost only\n")
        self.assertIsNone(suite_results.expected_output(test, "verilator"))
        self.assertIsNone(suite_results.expected_output(test))
        with self.assertRaises(ValueError):
            suite_results.expected_fields("icarus")

    def test_an_at_named_file_is_read_next_to_the_test(self):
        test = self.make(fields=":expected_stdout: @a.expected\n", files={"a.expected": "UT: ok\n"})
        self.assertEqual(suite_results.expected_output(test), "UT: ok\n")
        test = self.make(name="test_verilator_only",
                         fields=":expected_stdout_verilator: @v.expected\n",
                         files={"v.expected": "UT: v\n"})
        self.assertEqual(suite_results.expected_output(test, "verilator"), "UT: v\n")
        self.assertIsNone(suite_results.expected_output(test))


class Judgment(SuiteResults):
    def test_a_rejected_illegal_design_needs_a_matching_error_line(self):
        test = self.make(fields=":should_fail_because: illegal\n")
        self.assertEqual(suite_results.judge_illegal(test, True, "Error: nope"),
                         (False, "the design was accepted, but it is illegal"))
        self.assertEqual(suite_results.judge_illegal(test, False, "Error: bad thing at h.svh:3")[0],
                         False)  # no :expected_stderr_regex:
        test = self.make(name="test_regex",
                         fields=":should_fail_because: illegal\n"
                                ":expected_stderr_regex: h\\.svh\\(3\\)\n")
        self.assertEqual(suite_results.judge_illegal(test, False, "Error at h.svh(3): bad")[0], True)
        ok, why = suite_results.judge_illegal(test, False, "note: h.svh(3) here\nError: elsewhere\n")
        self.assertFalse(ok)
        self.assertIn("the first is: Error: elsewhere", why)

    def test_the_exit_code_and_messages_follow_their_fields(self):
        self.assertEqual(suite_results.judge_run(self.make(name="test_plain"), 3, "noise"), "")
        test = self.make(fields=":expected_exit: nonzero\n")
        self.assertEqual(suite_results.judge_run(test, 2, ""), "")
        self.assertEqual(suite_results.judge_run(test, 0, ""), "exit code 0, expected nonzero")
        # A run killed by a signal does not end with an error code.
        self.assertEqual(suite_results.judge_run(test, -9, ""), "exit code -9, expected nonzero")
        test = self.make(name="test_exit3", fields=":expected_exit: 3\n")
        self.assertEqual(suite_results.judge_run(test, 3, ""), "")
        self.assertEqual(suite_results.judge_run(test, 4, ""), "exit code 4, expected 3")
        test = self.make(name="test_msgs", fields=":expected_stderr_regex: ^UVM_FATAL.*\n")
        self.assertEqual(suite_results.judge_run(test, 1, "x\nUVM_FATAL f:1: dead"), "")
        self.assertIn("no message matches", suite_results.judge_run(test, 1, "quiet"))


class FirstDifference(SuiteResults):
    def test_reports_the_first_line_that_differs(self):
        self.assertEqual(suite_results.first_difference("a\nx\n", "a\nb\n"),
                         "line 2 is 'x', expected 'b'")
        self.assertEqual(suite_results.first_difference("a\n", "a\nb\n"),
                         "line 2 is missing, expected 'b'")
        self.assertEqual(suite_results.first_difference("a\nb\n", "a\n"),
                         "line 2 is extra: 'b'")

    def test_long_lines_are_shortened_and_line_end_differences_shown(self):
        got, want = "x" * 80, "y" * 80
        self.assertEqual(suite_results.first_difference(got + "\n", want + "\n"),
                         f"line 1 is '{got[:57]}...', expected '{want[:57]}...'")
        self.assertEqual(suite_results.first_difference("a\n", "a\r"), "the line ends differ")


class ResultJSON(SuiteResults):
    def setUp(self):
        super().setUp()
        for name in ("run_verilator.py", "suite_results.py", "uvm_common.py"):
            path = self.root / "tools" / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("x = 1\n")
        self.test = self.make(fields=":expected_stdout: UT: ok\n")
        self.out = self.root / "out/results.json"

    def written(self, inputs="capture", **kwargs):
        suite_results.write(self.out, "verilator", "Verilator", "Verilator 5.054 x",
                            {"u05/test_a": ("pass", "")},
                            inputs=suite_results.fingerprints([self.test])
                            if inputs == "capture" else inputs, **kwargs)
        return json.loads(self.out.read_text())

    def test_the_status_and_reason_are_written_sorted(self):
        suite_results.write(self.out, "verilator", "Verilator", "v",
                            {"u09/test_z": ("known", "differs"), "u05/test_a": ("fail", "")})
        data = json.loads(self.out.read_text())
        self.assertEqual(list(data["tests"]), ["u05/test_a", "u09/test_z"])
        self.assertEqual(data["tests"]["u09/test_z"], {"status": "known", "reason": "differs"})
        self.assertEqual(data["tests"]["u05/test_a"], {"status": "fail"})
        self.assertNotIn("generated_at", data)

    def test_an_unknown_status_is_refused(self):
        with self.assertRaises(AssertionError):
            suite_results.write(self.out, "verilator", "Verilator", "v",
                                {"u05/test_a": ("passed", "")})

    def test_the_record_keeps_the_fingerprint_only_while_the_inputs_are_unchanged(self):
        fingerprint = suite_results.fingerprints([self.test])
        data = self.written(inputs=fingerprint)
        self.assertEqual(data["tests"]["u05/test_a"]["inputs_sha256"], fingerprint["u05/test_a"])
        self.assertNotIn("inputs_changed", data["tests"]["u05/test_a"])
        self.test.write_text(self.test.read_text() + "// late edit\n")
        data = self.written(inputs=fingerprint)
        self.assertNotIn("inputs_sha256", data["tests"]["u05/test_a"])
        self.assertTrue(data["tests"]["u05/test_a"]["inputs_changed"])

    def test_the_record_flags_a_runner_that_changed_since_the_run(self):
        current = suite_results.runner_digest("verilator")
        data = self.written(runner_sha256=current)
        self.assertFalse(data["runner_changed"])
        self.assertEqual(data["runner_sha256"], current)
        data = self.written(runner_sha256="stale")
        self.assertTrue(data["runner_changed"])
        self.assertTrue(data["generated_at"].endswith("+00:00"))


if __name__ == "__main__":
    unittest.main()
