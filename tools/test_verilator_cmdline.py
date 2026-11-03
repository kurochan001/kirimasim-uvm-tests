"""Checks for explicit command-line opt-in, backend inputs and multi-seed judgments."""

import contextlib
import io
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import run_verilator_cmdline as cmdline
import suite_results
import lint_metadata


def result(stdout="UT: done\n", code=0):
    return subprocess.CompletedProcess([], code, stdout, "")


class CmdlineRunner(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.test = Path(self.temp.name) / "test_sample.sv"
        self.write()

    def write(self, extra=""):
        self.test.write_text(
            "/*\n:uvm: 2020.3.1\n:uvm_dpi: yes\n:uvm_cmdline_backend: vpi\n"
            ":uvm_cmdline_oracle: verilator@5.052\n"
            ":fourstate: no\n:uvm_defines: UVM_HDL_NO_DPI\n"
            f":dpi_c: @{cmdline.BACKEND}\n:files: {cmdline.REGEX} {cmdline.COMPAT}\n:expected_stdout: UT: done\n{extra}*/\n"
            "module test_sample; endmodule\n")

    def execute(self, runs):
        with (mock.patch.object(cmdline.uvm_common, "version_problem", return_value=""),
              mock.patch.object(cmdline.subprocess, "run", side_effect=[result(""), *runs]) as call):
            verdict = cmdline.run(self.test, "verilator", 1, 2, seeds=(1, 73))
        return verdict, call.call_args_list

    def test_two_seeds_build_once_with_the_declared_backend_and_vpi(self):
        verdict, calls = self.execute([result(), result()])
        self.assertEqual(verdict, (True, ""))
        self.assertEqual(len(calls), 3)
        self.assertIn("--vpi", calls[0].args[0])
        self.assertIn(str(cmdline.BACKEND), calls[0].args[0])
        self.assertNotIn("-DUVM_NO_DPI", calls[0].args[0])
        self.assertIn("+verilator+seed+1", calls[1].args[0])
        self.assertIn("+verilator+seed+73", calls[2].args[0])

    def test_second_seed_difference_is_not_hidden(self):
        verdict, _ = self.execute([result(), result("UT: wrong\n")])
        self.assertFalse(verdict[0])
        self.assertIn("seed 73: output differs", verdict[1])

    def test_complete_output_with_bad_exit_still_fails(self):
        verdict, _ = self.execute([result(code=2)])
        self.assertFalse(verdict[0])
        self.assertIn("nonzero exit", verdict[1])

    def test_unrelated_no_dpi_and_four_state_cases_are_refused_before_build(self):
        for old, new in [(":uvm_dpi: yes", ":uvm_dpi: no"),
                         (":uvm_cmdline_backend: vpi", ":uvm_cmdline_backend: other"),
                         (":fourstate: no", ":fourstate: yes"),
                         ("UVM_HDL_NO_DPI", "OTHER_MACRO"),
                         (str(cmdline.BACKEND), "/missing/backend.cpp")]:
            self.write()
            self.test.write_text(self.test.read_text().replace(old, new))
            with self.subTest(new=new), mock.patch.object(cmdline.subprocess, "run") as call:
                self.assertFalse(cmdline.run(self.test, "verilator", 1, 2)[0])
                call.assert_not_called()

    def test_disabled_dpi_is_refused_in_either_define_field(self):
        for field in ("uvm_defines", "defines"):
            for macro in ("UVM_REGEX_NO_DPI", "UVM_NO_DPI", "UVM_CMDLINE_NO_DPI"):
                self.write()
                text = self.test.read_text()
                if field == "uvm_defines":
                    text = text.replace("UVM_HDL_NO_DPI", "UVM_HDL_NO_DPI " + macro)
                else:
                    text = text.replace("*/", f":defines: {macro}\n*/")
                self.test.write_text(text)
                with self.subTest(field=field, macro=macro):
                    self.assertNotEqual(cmdline.backend_problem(self.test), "")

    def test_default_selection_requires_the_explicit_backend_marker(self):
        other = self.test.with_name("test_other.sv")
        other.write_text("/*\n:uvm_dpi: yes\n*/\nmodule test_other; endmodule\n")
        self.assertEqual(cmdline.selected([other, self.test]), [self.test])

    def test_default_selection_excludes_unmeasured_or_untagged_cases(self):
        other = self.test.with_name("test_other.sv")
        other.write_text(self.test.read_text().replace(
            ":uvm_cmdline_oracle: verilator@5.052\n", ""))
        self.assertEqual(cmdline.selected([other, self.test]), [self.test])
        self.assertEqual(cmdline.selected([other, self.test], all_tests=True),
                         [other, self.test])

    def test_unrecognized_condition_oracle_is_rejected_by_metadata_lint(self):
        self.test.write_text(self.test.read_text().replace(
            "verilator@5.052", "verilator@9.999"))
        errors = lint_metadata.problems(self.test, "2020.3.1")
        self.assertTrue(any(e.startswith("field: :uvm_cmdline_oracle:") for e in errors))

    def test_a_condition_oracle_without_backend_opt_in_is_rejected(self):
        for old, new in [(":uvm_cmdline_backend: vpi", ":uvm_cmdline_backend: other"),
                         (":uvm_dpi: yes", ":uvm_dpi: no")]:
            self.write()
            self.test.write_text(self.test.read_text().replace(old, new))
            with self.subTest(new=new):
                errors = lint_metadata.problems(self.test, "2020.3.1")
                self.assertTrue(any("requires the explicit VPI command-line backend" in e
                                    for e in errors))

    def test_untagged_difference_remains_known_and_is_not_counted_as_a_pass(self):
        self.test.write_text(self.test.read_text().replace(
            ":uvm_cmdline_oracle: verilator@5.052\n", ""))
        stream = io.StringIO()
        with (mock.patch.object(sys, "argv", ["run_verilator_cmdline.py", "--all",
                                               "--json", "unused.json", str(self.test)]),
              mock.patch.object(suite_results, "tool_version", return_value="Verilator 5.052 test"),
              mock.patch.object(suite_results, "fingerprints", return_value={"test_sample": "input"}),
              mock.patch.object(suite_results, "test_id", return_value="test_sample"),
              mock.patch.object(suite_results, "write") as output,
              mock.patch.object(cmdline, "run", return_value=(False, "seed 1: difference")),
              contextlib.redirect_stdout(stream)):
            self.assertEqual(cmdline.main(), 0)
        self.assertEqual(output.call_args.args[4]["test_sample"][0], "known")
        self.assertIn("0/1 command-line fixtures match; 1 known", stream.getvalue())

    def test_each_repository_cmdline_fixture_fingerprints_the_backend(self):
        fixtures = cmdline.selected(suite_results.find_tests(), all_tests=True)
        self.assertGreaterEqual(len(fixtures), 2)
        for test in fixtures:
            with self.subTest(test=test):
                self.assertTrue({cmdline.BACKEND, cmdline.REGEX, cmdline.COMPAT}
                                <= set(suite_results.input_files(test)))
                self.assertEqual(cmdline.backend_problem(test), "")

    def test_cli_refuses_a_different_verilator_version(self):
        with (mock.patch.object(sys, "argv", ["run_verilator_cmdline.py", str(self.test)]),
              mock.patch.object(suite_results, "tool_version", return_value="Verilator 5.054"),
              mock.patch.object(cmdline, "run") as execute,
              contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error):
            cmdline.main()
        self.assertEqual(error.exception.code, 2)
        execute.assert_not_called()

    def test_cli_records_failure_as_failure_under_its_separate_runner_identity(self):
        with (mock.patch.object(sys, "argv", ["run_verilator_cmdline.py", "--json", "unused.json",
                                               str(self.test)]),
              mock.patch.object(suite_results, "tool_version", return_value="Verilator 5.052 test"),
              mock.patch.object(suite_results, "fingerprints",
                                return_value={"test_sample": "input"}),
              mock.patch.object(suite_results, "test_id", return_value="test_sample"),
              mock.patch.object(suite_results, "write") as output,
              mock.patch.object(cmdline, "run", return_value=(False, "seed 73: difference")),
              contextlib.redirect_stdout(io.StringIO())):
            self.assertEqual(cmdline.main(), 1)
        self.assertEqual(output.call_args.args[1], "verilator_cmdline")
        self.assertEqual(output.call_args.args[4]["test_sample"][0], "fail")
        self.assertEqual(output.call_args.kwargs["configuration"]["seeds"], [1, 73])


if __name__ == "__main__":
    unittest.main()
