"""Regression checks for multi-seed judgments and private Ghost evidence."""

import contextlib
import io
import json
import signal
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import run_ghost
import run_verilator
import suite_results
import uvm_common
import fetch_uvm

PROFILE = {"arguments": ["--quiet"], "environment": {"PRIVATE_SETTING": "1"},
           "uvm_mode": "bundled", "uvm_embedded": True}


def result(stdout="UT: done\n", code=0, stderr=""):
    return subprocess.CompletedProcess([], code, stdout, stderr)


class RunnerTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.test = self.root / "tests/u05/test_sample.sv"
        self.test.parent.mkdir(parents=True)
        self.write()

    def write(self, extra=""):
        self.test.write_text("/*\n:uvm: 2020.3.1\n:expected_stdout: UT: done\n"
                             + extra + "\n*/\nmodule test_sample; endmodule\n")


class VerilatorSeeds(RunnerTest):
    def execute(self, runs):
        with (mock.patch.object(run_verilator.uvm_common, "version_problem", return_value=""),
              mock.patch.object(run_verilator.subprocess, "run",
                                side_effect=[result(""), *runs]) as execute):
            verdict = run_verilator.run(self.test, "verilator", 1, 1, seeds=(1, 73))
        return verdict, execute.call_args_list

    def test_two_seeds_share_one_build_but_use_fresh_processes(self):
        verdict, calls = self.execute([result(), result()])
        self.assertEqual(verdict, (True, ""))
        self.assertEqual(len(calls), 3)
        self.assertIn("--binary", calls[0].args[0])
        self.assertIn("+verilator+seed+1", calls[1].args[0])
        self.assertIn("+verilator+seed+73", calls[2].args[0])

    def test_second_seed_failure_is_not_hidden_by_first_seed_pass(self):
        verdict, _ = self.execute([result(), result("UT: wrong\n")])
        self.assertFalse(verdict[0])
        self.assertIn("seed 73: output differs", verdict[1])

    def test_crash_after_complete_observations_fails(self):
        verdict, _ = self.execute([result(code=-signal.SIGSEGV)])
        self.assertFalse(verdict[0])
        self.assertIn("crashed", verdict[1])

    def test_nonzero_exit_after_complete_observations_fails(self):
        verdict, _ = self.execute([result(code=2)])
        self.assertFalse(verdict[0])
        self.assertIn("nonzero exit", verdict[1])

    def test_declared_nonzero_exit_is_still_supported(self):
        self.write(":expected_exit: nonzero")
        verdict, _ = self.execute([result(code=2), result(code=2)])
        self.assertEqual(verdict, (True, ""))


class GhostEvidence(RunnerTest):
    def execute(self, completed, profile=None):
        with mock.patch.object(run_ghost.subprocess, "run", return_value=completed) as execute:
            verdict = run_ghost.run(self.test, "/private/simulator", profile or PROFILE)
        return verdict, execute.call_args

    def test_bundled_library_does_not_compile_a_second_package(self):
        verdict, call = self.execute(result())
        self.assertEqual(verdict, ("pass", ""))
        self.assertNotIn(str(uvm_common.sources()[0]), call.args[0])
        self.assertEqual(call.kwargs["env"]["PRIVATE_SETTING"], "1")

    def test_pinned_library_precedes_the_test_sources(self):
        profile = {k: v for k, v in PROFILE.items() if k != "uvm_embedded"}
        with mock.patch.object(uvm_common, "version_problem", return_value=""):
            verdict, call = self.execute(result(), {**profile, "uvm_mode": "pinned"})
        self.assertEqual(verdict, ("pass", ""))
        command = call.args[0]
        self.assertLess(command.index(str(uvm_common.sources()[0])), command.index(str(self.test)))
        self.assertIn("+define+UVM_NO_DPI", command)

    def test_private_output_is_not_in_failure_reasons(self):
        verdict, _ = self.execute(result("private-brand internal.cpp:42\n", 255,
                                         "/private/source/file.cpp:2: error: secret"))
        self.assertEqual(verdict, ("fail", "output differs"))

    def test_crash_and_unexpected_exit_fail_even_after_complete_output(self):
        for code in (-signal.SIGSEGV, 2):
            with self.subTest(code=code):
                verdict, _ = self.execute(result(code=code))
                self.assertEqual(verdict[0], "fail")

    def test_declared_exit_and_required_diagnostic_are_checked(self):
        self.write(":expected_exit: nonzero\n:expected_stderr_regex: expected failure")
        verdict, _ = self.execute(result(code=2, stderr="expected failure"))
        self.assertEqual(verdict, ("pass", ""))
        verdict, _ = self.execute(result(code=2, stderr="secret error"))
        self.assertEqual(verdict[0], "fail")
        self.assertNotIn("secret", verdict[1])

    def test_illegal_test_requires_matching_error_and_scrubs_actual_diagnostics(self):
        self.write(":should_fail_because: invalid declaration\n"
                   ":expected_stderr_regex: invalid declaration")
        verdict, _ = self.execute(result("", 2, "private.cpp:2: error: invalid declaration"))
        self.assertEqual(verdict, ("pass", ""))
        verdict, _ = self.execute(result("", 2, "private.cpp:2: error: secret"))
        self.assertEqual(verdict, ("fail", "no error matches 'invalid declaration'"))

    def test_timeout_does_not_expose_partial_output(self):
        with mock.patch.object(run_ghost.subprocess, "run", side_effect=
                               subprocess.TimeoutExpired("private-name", 300,
                                                         output="private.cpp:1")):
            self.assertEqual(run_ghost.run(self.test, "/private/simulator", PROFILE),
                             ("fail", "timed out"))

    def test_profile_requires_explicit_library_mode_and_typed_arguments(self):
        for profile in ({}, {**PROFILE, "uvm_mode": "unknown"},
                        {**PROFILE, "arguments": "--quiet"},
                        {**PROFILE, "environment": {"KEY": 1}},
                        {**PROFILE, "uvm_library_dir": "/private/uvm"},
                        {k: v for k, v in PROFILE.items() if k != "uvm_embedded"}):
            with self.subTest(profile=profile), self.assertRaises(ValueError):
                run_ghost.parse_profile(json.dumps(profile).encode())

    def cli(self, mode, execute=None, library_dir=None):
        executable = self.root / "private-brand"
        executable.write_text(f"#!{sys.executable}\nprint('private-brand secret.cpp:42')\n")
        executable.chmod(0o700)
        profile = self.root / "private-profile.json"
        settings = {**PROFILE, "uvm_mode": mode}
        if mode == "pinned" or library_dir is not None:
            settings.pop("uvm_embedded")
        if library_dir is not None:
            settings["uvm_library_dir"] = str(library_dir)
        profile.write_text(json.dumps(settings))
        output = self.root / "result.json"
        log = io.StringIO()
        with (mock.patch.object(suite_results, "ROOT", self.root),
              mock.patch.object(suite_results, "runner_digest", return_value="runner"),
              mock.patch.object(sys, "argv", ["run_ghost.py", "--simulator", str(executable),
                                             "--profile", str(profile), "--json", str(output),
                                             str(self.test)]),
              contextlib.redirect_stdout(log)):
            if execute is None:
                code = run_ghost.main()
            else:
                with mock.patch.object(run_ghost, "run", side_effect=execute):
                    code = run_ghost.main()
        return code, log.getvalue(), output, profile

    def test_public_results_keep_private_identity_out_and_mark_bundled_library(self):
        code, log, output, _ = self.cli("bundled")
        self.assertEqual(code, 1)
        data = json.loads(output.read_text())
        self.assertEqual(data["configuration"]["uvm_source"], "bundled")
        self.assertFalse(data["configuration"]["uvm_pinned"])
        self.assertNotIn("uvm_content_sha256", data["configuration"])
        self.assertRegex(data["version"], r"^private build [0-9a-f]{12}$")
        for private in ("private-brand", "secret.cpp", str(self.root), "PRIVATE_SETTING"):
            self.assertNotIn(private, log + output.read_text())

    def test_pinned_results_record_the_library_digest(self):
        library = {"uvm_library": "pinned",
                   "uvm_content_sha256": uvm_common.lock()["content_sha256"],
                   "uvm_files": uvm_common.lock()["files"]}
        with mock.patch.object(run_ghost, "library_state", return_value=library):
            code, _, output, _ = self.cli("pinned", lambda *args: ("pass", ""))
        self.assertEqual(code, 0)
        configuration = json.loads(output.read_text())["configuration"]
        self.assertTrue(configuration["uvm_pinned"])
        self.assertEqual(configuration["uvm_content_sha256"],
                         uvm_common.lock()["content_sha256"])

    def test_changed_profile_discards_results(self):
        def change_profile(*args):
            (self.root / "private-profile.json").write_text("{}")
            return "pass", ""

        with contextlib.redirect_stderr(io.StringIO()):
            code, _, output, _ = self.cli("bundled", change_profile)
        self.assertEqual(code, 2)
        self.assertFalse(output.exists())

    def library(self):
        directory = self.root / "private-library"
        directory.mkdir()
        (directory / "uvm_pkg.sv").write_text("package uvm_pkg; endpackage\n")
        return directory

    def test_bundled_library_digest_is_canonical_and_paths_stay_private(self):
        directory = self.library()
        value, count = fetch_uvm.digest(directory)
        code, log, output, _ = self.cli("bundled", lambda *args: ("pass", ""), directory)
        self.assertEqual(code, 0)
        configuration = json.loads(output.read_text())["configuration"]
        self.assertEqual(configuration["uvm_content_sha256"], value)
        self.assertEqual(configuration["uvm_files"], count)
        self.assertFalse(configuration["uvm_pinned"])
        self.assertNotIn(str(directory), log + output.read_text())

    def test_library_change_discards_results_even_with_unchanged_executable(self):
        directory = self.library()

        def change_library(*args):
            (directory / "uvm_pkg.sv").write_text("package uvm_pkg; int changed; endpackage\n")
            return "pass", ""

        with contextlib.redirect_stderr(io.StringIO()):
            code, _, output, _ = self.cli("bundled", change_library, directory)
        self.assertEqual(code, 2)
        self.assertFalse(output.exists())

    def test_pinned_mode_refuses_a_library_that_differs_from_the_lock(self):
        directory = self.library()
        with (mock.patch.object(uvm_common, "library_dir", return_value=directory),
              self.assertRaises(ValueError)):
            run_ghost.library_state({"uvm_mode": "pinned"})


if __name__ == "__main__":
    unittest.main()
