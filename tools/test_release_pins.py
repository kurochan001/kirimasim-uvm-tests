"""Cross-checks of the pinned Verilator release.

The runners name the release the tags record: tools/run_verilator.py keeps it
in RELEASE and derives the version check and the tag from it, but the DPI
condition runners write the release into their version check and error text,
and .github/actions/setup-verilator builds and requires it again. These tests
hold the two spellings, the condition runners' gates and the action together,
so a migration that moves one and not the others fails here.
"""

import contextlib
import io
import re
import sys
import unittest
from pathlib import Path
from unittest import mock

import run_verilator
import run_verilator_cmdline as cmdline
import run_verilator_hdl as hdl
import run_verilator_regex as regex
import lint_metadata

ROOT = Path(__file__).resolve().parent.parent
ACTION = ROOT / ".github" / "actions" / "setup-verilator" / "action.yml"


def call_main(module, version, argv):
    """main() under a recorded `verilator --version` and argv; returns (code, stderr)."""
    with (mock.patch.object(module.suite_results, "tool_version", return_value=version),
          mock.patch.object(sys, "argv", argv),
          mock.patch("sys.stderr", new_callable=io.StringIO) as err,
          mock.patch("sys.stdout", new_callable=io.StringIO)):
        try:
            return module.main(), err.getvalue()
        except SystemExit as stop:
            return stop.code, err.getvalue()


class ReleaseConstants(unittest.TestCase):
    def test_the_condition_runners_tag_the_release_the_suite_names(self):
        for module in (cmdline, regex):
            with self.subTest(module=module.__name__):
                self.assertEqual(module.ORACLE, run_verilator.ORACLE)
                self.assertEqual(module.ORACLE, f"verilator@{run_verilator.RELEASE}")

    def test_the_setup_action_builds_and_requires_only_that_release(self):
        text = ACTION.read_text(encoding="utf-8")
        spelled = re.findall(r"Verilator (\d+\.\d+)", text)
        keyed = re.findall(r"verilator-v(\d+\.\d+)", text)
        self.assertTrue(spelled and keyed)
        for found in spelled + keyed:
            self.assertEqual(found, run_verilator.RELEASE,
                             ".github/actions/setup-verilator/action.yml names a release"
                             " the runners do not")

    def test_the_metadata_lint_allows_only_the_pinned_tags(self):
        # The lint admits the oracle tags; a migration that moves the runners
        # and the action but not the lint would reject every retagged test,
        # and one that only moves the lint would admit tags no runner keeps.
        self.assertEqual(lint_metadata.ORACLES, {"spec", run_verilator.ORACLE})
        self.assertEqual(lint_metadata.CHOICES["uvm_cmdline_oracle"], {cmdline.ORACLE})


class ConditionVersionGates(unittest.TestCase):
    """Each condition runner refuses a release other than the pinned one."""

    def test_cmdline_refuses_another_release_and_passes_the_gate_otherwise(self):
        code, err = call_main(cmdline, "Verilator 5.056 2027-01-01 rev v5.056",
                              ["run_verilator_cmdline.py"])
        self.assertEqual(code, 2)
        self.assertIn(f"Verilator {run_verilator.RELEASE}", err)
        with mock.patch.object(cmdline, "selected", return_value=[]):
            code, err = call_main(cmdline, f"Verilator {run_verilator.RELEASE} 2026-11-01 rev v",
                                  ["run_verilator_cmdline.py"])
        self.assertEqual(code, 2)
        self.assertIn("no command-line fixtures selected", err)

    def test_hdl_refuses_another_release_and_passes_the_gate_otherwise(self):
        code, err = call_main(hdl, "Verilator 5.053 2026-01-01 rev v5.053",
                              ["run_verilator_hdl.py"])
        self.assertEqual(code, 2)
        self.assertIn(f"Verilator {run_verilator.RELEASE}", err)
        with mock.patch.object(hdl, "selected", return_value=[]):
            code, err = call_main(hdl, f"Verilator {run_verilator.RELEASE} 2026-11-01 rev v",
                                  ["run_verilator_hdl.py"])
        self.assertEqual(code, 2)
        self.assertIn("no VPI HDL fixtures selected", err)

    def test_regex_refuses_another_release_and_passes_the_gate_otherwise(self):
        code, err = call_main(regex, "Verilator 5.056 2027-01-01 rev v5.056",
                              ["run_verilator_regex.py"])
        self.assertEqual(code, 2)
        self.assertIn(f"Verilator {run_verilator.RELEASE}", err)
        with mock.patch.object(regex, "variants", return_value={}):
            code, err = call_main(regex, f"Verilator {run_verilator.RELEASE} 2026-11-01 rev v",
                                  ["run_verilator_regex.py",
                                   str(ROOT / "tests/uA/test_absent.sv")])
        self.assertEqual(code, 2)
        self.assertIn("not listed in coverage/regex_dpi_variants.txt", err)

    def test_only_the_ordinary_runner_offers_a_survey_release(self):
        # The conditions' tags say the evidence came from that condition's
        # release; a survey has no place in them, so only the ordinary runner
        # carries --any-release.
        code, err = call_main(cmdline, "Verilator 5.056 2027-01-01 rev v5.056",
                              ["run_verilator_cmdline.py", "--any-release"])
        self.assertEqual(code, 2)
        self.assertIn("unrecognized arguments: --any-release", err)
        code, err = call_main(regex, "Verilator 5.056 2027-01-01 rev v5.056",
                              ["run_verilator_regex.py", "--any-release"])
        self.assertEqual(code, 2)
        self.assertIn("unrecognized arguments: --any-release", err)


if __name__ == "__main__":
    unittest.main()
