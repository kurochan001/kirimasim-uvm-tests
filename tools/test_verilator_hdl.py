"""Checks for explicit HDL opt-in, backend inputs and multi-seed judgments."""

import contextlib
import io
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import run_verilator_hdl as hdl
import suite_results


def result(stdout="UT: done\n", code=0):
    return subprocess.CompletedProcess([], code, stdout, "")


class HdlRunner(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.test = Path(self.temp.name) / "test_sample.sv"
        self.write()

    def write(self, extra=""):
        self.test.write_text(
            "/*\n:uvm: 2020.3.1\n:uvm_dpi: yes\n:uvm_hdl_backend: vpi\n"
            ":fourstate: no\n:uvm_defines: UVM_REGEX_NO_DPI UVM_CMDLINE_NO_DPI\n"
            f":dpi_c: @{hdl.BACKEND}\n:expected_stdout: UT: done\n{extra}*/\n"
            "module test_sample; endmodule\n")

    def execute(self, runs):
        with (mock.patch.object(hdl.uvm_common, "version_problem", return_value=""),
              mock.patch.object(hdl.subprocess, "run", side_effect=[result(""), *runs]) as call):
            verdict = hdl.run(self.test, "verilator", 1, 2, seeds=(1, 73))
        return verdict, call.call_args_list

    def test_two_seeds_build_once_with_the_declared_backend_and_vpi(self):
        verdict, calls = self.execute([result(), result()])
        self.assertEqual(verdict, (True, ""))
        self.assertEqual(len(calls), 3)
        self.assertIn("--vpi", calls[0].args[0])
        self.assertIn(str(hdl.BACKEND), calls[0].args[0])
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
                         (":uvm_hdl_backend: vpi", ":uvm_hdl_backend: other"),
                         (":fourstate: no", ":fourstate: yes"),
                         ("UVM_REGEX_NO_DPI", "OTHER_MACRO"),
                         (str(hdl.BACKEND), "/missing/backend.cpp")]:
            self.write()
            self.test.write_text(self.test.read_text().replace(old, new))
            with self.subTest(new=new), mock.patch.object(hdl.subprocess, "run") as call:
                self.assertFalse(hdl.run(self.test, "verilator", 1, 2)[0])
                call.assert_not_called()

    def test_abi_override_or_disabled_hdl_is_refused_in_either_define_field(self):
        for field in ("uvm_defines", "defines"):
            for macro in ("UVM_HDL_MAX_WIDTH=2048", "UVM_NO_DPI", "UVM_HDL_NO_DPI"):
                self.write()
                text = self.test.read_text()
                if field == "uvm_defines":
                    text = text.replace("UVM_CMDLINE_NO_DPI", "UVM_CMDLINE_NO_DPI " + macro)
                else:
                    text = text.replace("*/", f":defines: {macro}\n*/")
                self.test.write_text(text)
                with self.subTest(field=field, macro=macro):
                    self.assertNotEqual(hdl.backend_problem(self.test), "")

    def test_default_selection_requires_the_explicit_backend_marker(self):
        other = self.test.with_name("test_other.sv")
        other.write_text("/*\n:uvm_dpi: yes\n*/\nmodule test_other; endmodule\n")
        self.assertEqual(hdl.selected([other, self.test]), [self.test])

    def test_each_repository_hdl_fixture_fingerprints_the_backend(self):
        fixtures = hdl.selected(suite_results.find_tests())
        self.assertGreaterEqual(len(fixtures), 2)
        for test in fixtures:
            with self.subTest(test=test):
                self.assertIn(hdl.BACKEND, suite_results.input_files(test))
                self.assertEqual(hdl.backend_problem(test), "")

    def test_cli_refuses_a_different_verilator_version(self):
        with (mock.patch.object(sys, "argv", ["run_verilator_hdl.py", str(self.test)]),
              mock.patch.object(suite_results, "tool_version", return_value="Verilator 5.054"),
              mock.patch.object(hdl, "run") as execute,
              contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error):
            hdl.main()
        self.assertEqual(error.exception.code, 2)
        execute.assert_not_called()

    def test_cli_records_failure_as_failure_under_its_separate_runner_identity(self):
        with (mock.patch.object(sys, "argv", ["run_verilator_hdl.py", "--json", "unused.json",
                                               str(self.test)]),
              mock.patch.object(suite_results, "tool_version", return_value="Verilator 5.052 test"),
              mock.patch.object(suite_results, "fingerprints",
                                return_value={"test_sample": "input"}),
              mock.patch.object(suite_results, "test_id", return_value="test_sample"),
              mock.patch.object(suite_results, "write") as output,
              mock.patch.object(hdl, "run", return_value=(False, "seed 73: difference")),
              contextlib.redirect_stdout(io.StringIO())):
            self.assertEqual(hdl.main(), 1)
        self.assertEqual(output.call_args.args[1], "verilator_hdl")
        self.assertEqual(output.call_args.args[4]["test_sample"][0], "fail")
        self.assertEqual(output.call_args.kwargs["configuration"]["seeds"], [1, 73])


if __name__ == "__main__":
    unittest.main()
