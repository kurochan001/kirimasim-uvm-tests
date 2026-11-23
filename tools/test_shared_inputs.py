"""Cross-checks of the inputs the runners share.

The report declarations and the UVM library lock are read by every runner and
by their own checking tools. Each module spells the path out, so a move that
updates one and not the others would silently split the evidence: some runners
would record one file and other tools would check another. These tests hold
the spellings together, and check how uvm_common answers for the pinned
library: which version a test asks for, and whether it is where it should be.
"""

import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

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

TEST_HEADER = "/*\n:name: test_a\n:type: simulation\n:uvm: {uvm}\n*/\nmodule test_a; endmodule\n"


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
        package = target / "src" / "uvm_pkg.sv"
        self.assertEqual(uvm_common.sources(), [package])
        self.assertTrue(package.is_file(), "the runner's UVM package is missing")

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


class LibraryVersion(unittest.TestCase):
    """uvm_common answers whether the pinned library can run a test."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        for module in (uvm_common,):
            patch = mock.patch.object(module, "ROOT", self.root)
            patch.start()
            self.addCleanup(patch.stop)
        patch = mock.patch.object(uvm_common, "LOCK", self.root / "third_party/uvm.lock")
        patch.start()
        self.addCleanup(patch.stop)
        self.test = self.root / "tests/u05/test_a.sv"
        self.test.parent.mkdir(parents=True)

    def lock(self, version):
        uvm_common.LOCK.parent.mkdir(parents=True, exist_ok=True)
        uvm_common.LOCK.write_text(json.dumps({"version": version}))

    def test_the_lock_names_the_dir_and_the_sources_of_the_library(self):
        self.lock("1.2")
        self.assertEqual(uvm_common.library_dir(), self.root / "third_party/uvm/1.2")
        self.assertEqual(uvm_common.include_dirs(), [uvm_common.library_dir() / "src"])
        self.assertEqual(uvm_common.sources(),
                         [uvm_common.library_dir() / "src/uvm_pkg.sv"])

    def test_a_test_naming_another_library_version_is_not_run(self):
        self.lock("2020.3.1")
        self.test.write_text(TEST_HEADER.format(uvm="2017.1.12"))
        problem = uvm_common.version_problem(self.test)
        self.assertIn("2017.1.12", problem)
        self.assertIn("2020.3.1", problem)

    def test_an_unfetched_library_says_what_to_run(self):
        self.lock("2020.3.1")
        self.test.write_text(TEST_HEADER.format(uvm="2020.3.1"))
        self.assertIn("fetch_uvm", uvm_common.version_problem(self.test))

    def test_a_matching_fetched_library_has_no_problem(self):
        self.lock("2020.3.1")
        pkg = uvm_common.library_dir() / "src/uvm_pkg.sv"
        pkg.parent.mkdir(parents=True)
        pkg.write_text("package uvm_pkg; endpackage\n")
        self.test.write_text(TEST_HEADER.format(uvm="2020.3.1"))
        self.assertEqual(uvm_common.version_problem(self.test), "")


if __name__ == "__main__":
    unittest.main()
