"""Checks for the regex-DPI variant list, its eligibility rules and the variant build."""

import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import run_verilator_regex as regex
import suite_results


def result(stdout="UT: done\n", code=0):
    return subprocess.CompletedProcess([], code, stdout, "")


class VariantList(unittest.TestCase):
    def parse(self, text):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "list.txt"
            path.write_text(text)
            return regex.variants(path)

    def test_comments_blank_lines_and_tags_are_read_in_order(self):
        entries = self.parse("# heading\n\nuA/test_one\nuB/test_two verilator@5.052  # note\n")
        self.assertEqual(list(entries.items()), [("uA/test_one", False), ("uB/test_two", True)])

    def test_unknown_tags_extra_words_and_duplicates_are_rejected(self):
        for text in ("uA/test_one other\n", "uA/test_one verilator@5.052 extra\n",
                     "uA/test_one\nuA/test_one verilator@5.052\n"):
            with self.subTest(text=text), self.assertRaises(ValueError):
                self.parse(text)

    def test_every_listed_fixture_exists_and_is_eligible(self):
        entries = regex.variants()
        self.assertTrue(entries)
        for name in entries:
            test = suite_results.ROOT / "tests" / (name + ".sv")
            with self.subTest(name=name):
                self.assertTrue(test.is_file())
                self.assertEqual(regex.variant_problem(test), "")


class VariantBuild(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.test = Path(self.temp.name) / "test_sample.sv"
        self.write()

    def write(self, extra=""):
        self.test.write_text("/*\n:uvm: 2020.3.1\n:fourstate: no\n:expected_stdout: UT: done\n"
                             f"{extra}*/\nmodule test_sample; endmodule\n")

    def execute(self, runs):
        with (mock.patch.object(regex.uvm_common, "version_problem", return_value=""),
              mock.patch.object(regex.subprocess, "run", side_effect=[result(""), *runs]) as call):
            verdict = regex.run(self.test, "verilator", 1, 2, seeds=(1, 73))
        return verdict, call.call_args_list

    def test_build_replaces_no_dpi_with_hdl_only_and_adds_both_backends(self):
        verdict, calls = self.execute([result(), result()])
        self.assertEqual(verdict, (True, ""))
        build = calls[0].args[0]
        self.assertIn("--vpi", build)
        self.assertIn(str(regex.BACKEND), build)
        self.assertIn(str(regex.REGEX), build)
        self.assertIn("-DUVM_HDL_NO_DPI", build)
        for macro in ("UVM_NO_DPI", "UVM_REGEX_NO_DPI", "UVM_CMDLINE_NO_DPI"):
            self.assertNotIn(f"-D{macro}", build)
        self.assertIn("+verilator+seed+1", calls[1].args[0])
        self.assertIn("+verilator+seed+73", calls[2].args[0])

    def test_second_seed_difference_is_not_hidden(self):
        verdict, _ = self.execute([result(), result("UT: wrong\n")])
        self.assertFalse(verdict[0])
        self.assertIn("seed 73: output differs", verdict[1])

    def test_fixtures_outside_the_condition_are_refused_before_build(self):
        for extra in (":uvm_dpi: yes\n", ":should_fail_because: illegal\n"):
            self.write(extra)
            with self.subTest(extra=extra), mock.patch.object(regex.subprocess, "run") as call:
                self.assertFalse(regex.run(self.test, "verilator", 1, 2)[0])
                call.assert_not_called()
        self.write()
        self.test.write_text(self.test.read_text().replace(":fourstate: no", ":fourstate: yes"))
        with mock.patch.object(regex.subprocess, "run") as call:
            self.assertFalse(regex.run(self.test, "verilator", 1, 2)[0])
            call.assert_not_called()


if __name__ == "__main__":
    unittest.main()
