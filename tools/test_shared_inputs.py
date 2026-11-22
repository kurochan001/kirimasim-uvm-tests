"""Cross-checks of the inputs the runners share.

The report declarations and the UVM library lock are read by every runner and
by their own checking tools. Each module spells the path out, so a move that
updates one and not the others would silently split the evidence: some runners
would record one file and other tools would check another. These tests hold
the spellings together.
"""

import unittest

import fetch_uvm
import run_ghost
import run_kirimasim
import run_verilator
import run_verilator_cmdline as cmdline
import run_verilator_hdl as hdl
import run_verilator_regex as regex
import suite_results
import uvm_common
import uvm_reports


class ReportDeclarations(unittest.TestCase):
    def test_every_consumer_reads_the_one_file_the_tool_checks(self):
        # Each module spells the path out; the sha of the file belongs to the
        # record, so a runner must not read a different file than the one the
        # checking tool validates.
        for module in (run_verilator, run_kirimasim, cmdline, hdl, regex):
            with self.subTest(module=module.__name__):
                self.assertEqual(module.DECLARATIONS, uvm_reports.DEFAULT)
        self.assertTrue(uvm_reports.DEFAULT.is_file())


class LibraryLock(unittest.TestCase):
    def test_the_fetcher_and_the_runners_lock_the_same_file(self):
        self.assertEqual(fetch_uvm.LOCK, uvm_common.LOCK)
        self.assertTrue(uvm_common.LOCK.is_file())

    def test_the_lock_names_the_library_the_runners_build_with(self):
        lock = uvm_common.lock()
        self.assertEqual(lock["version"], "2020.3.1")
        target = uvm_common.ROOT / "third_party" / "uvm" / lock["version"]
        self.assertTrue(target.is_dir(), "fetch_uvm places the library where uvm_common reads it")
        self.assertTrue((target / "src" / "uvm_pkg.sv").is_file()
                        or list(target.rglob("uvm_pkg.sv")), "the library holds uvm_pkg.sv")

    def test_the_condition_records_name_the_locked_library(self):
        # The two runners that link the regex DPI write the library version
        # into their result condition as a name, not a digest. A library
        # migration that moves the lock but not these strings would record
        # results under a condition the library no longer matches.
        named = uvm_common.lock()["version"]
        for module in (cmdline, regex):
            with self.subTest(module=module.__name__):
                self.assertIn(f'"regex_dpi": "pinned-uvm-{named}"',
                              (uvm_common.ROOT / "tools" / f"{module.__name__}.py"
                               ).read_text(encoding="utf-8"))

    def test_ghost_kirimasim_and_verilator_share_the_uvm_helpers(self):
        for module in (run_ghost, run_kirimasim, run_verilator):
            with self.subTest(module=module.__name__):
                self.assertIs(module.uvm_common, uvm_common)
                self.assertIs(module.suite_results, suite_results)


if __name__ == "__main__":
    unittest.main()
