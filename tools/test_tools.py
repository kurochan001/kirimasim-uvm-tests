"""Unit tests of the tools: the observed lines, the UVM macros, the library
digest and the metadata checks."""

import io
import tarfile
import tempfile
import unittest
from pathlib import Path

import fetch_uvm
import lint_metadata
import suite_results
import uvm_common

HEADER = """/*
:name: {name}
:description: a sample
:tags: {tags}
:type: simulation
:lrm: {lrm}
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
{extra}:expected_stdout: @{name}.expected
*/
{body}
module {name}; endmodule
"""


class Sample(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()

    def make(self, folder="u09", name="test_sample", tags="u09 uvm", lrm="1800.2-2020 9.8.1",
             extra="", body="", expected="UT: one\n"):
        path = self.root / folder / f"{name}.sv"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(HEADER.format(name=name, tags=tags, lrm=lrm, extra=extra, body=body))
        path.with_suffix(".expected").write_text(expected)
        return path


class ObservedLines(Sample):
    def test_only_lines_with_the_prefix_are_kept(self):
        out = "UVM_INFO x.svh(1) @ 0: reporter [RNTST] Running test t...\nUT: a\n  UT: b\nUT: c\n"
        self.assertEqual(uvm_common.observed(out), "UT: a\nUT: c\n")

    def test_dpi_is_off_unless_the_test_asks_for_it(self):
        self.assertEqual(uvm_common.defines(self.make()), ["UVM_NO_DPI"])
        dpi = self.make(name="test_dpi", extra=":uvm_dpi: yes\n:uvm_defines: UVM_HDL_NO_DPI\n")
        self.assertEqual(uvm_common.defines(dpi), ["UVM_HDL_NO_DPI"])

    def test_the_lock_is_an_input_of_every_test(self):
        test = next(iter(suite_results.find_tests()))
        self.assertIn(uvm_common.LOCK.resolve(), suite_results.input_files(test))


class LibraryDigest(Sample):
    def test_digest_depends_on_names_and_contents_only(self):
        a, b = self.root / "a", self.root / "b"
        for top in (a, b):
            (top / "src").mkdir(parents=True)
            (top / "src" / "x.sv").write_text("one\n")
        self.assertEqual(fetch_uvm.digest(a), fetch_uvm.digest(b))
        (b / "src" / "x.sv").write_text("two\n")
        self.assertNotEqual(fetch_uvm.digest(a), fetch_uvm.digest(b))

    def test_an_archive_member_outside_its_directory_is_refused(self):
        data = io.BytesIO()
        with tarfile.open(fileobj=data, mode="w:gz") as archive:
            info = tarfile.TarInfo("../escape.txt")
            info.size = 1
            archive.addfile(info, io.BytesIO(b"x"))
        with self.assertRaises(ValueError):
            fetch_uvm.extract(data.getvalue(), self.root)


class Metadata(Sample):
    def check(self, path):
        return lint_metadata.problems(path, "2020.3.1")

    def test_the_suite_has_no_problems(self):
        for test in suite_results.find_tests():
            self.assertEqual(self.check(test), [], test)

    def test_a_good_sample_passes(self):
        self.assertEqual(self.check(self.make()), [])

    def test_directory_tags_and_clause_follow_the_first_clause(self):
        found = self.check(self.make(folder="u10"))
        self.assertTrue(any(p.startswith("directory:") for p in found), found)
        found = self.check(self.make(name="test_bad_tags", tags="u10 uvm"))
        self.assertTrue(any(p.startswith("tags:") for p in found), found)
        found = self.check(self.make(name="test_bad_clause", lrm="1800.2-2020 99.1"))
        self.assertTrue(any("99.1 is not a clause" in p for p in found), found)

    def test_annex_clauses_map_to_letter_directories(self):
        self.assertEqual(lint_metadata.chapter_dir("C.4.2"), "uC")
        self.assertEqual(lint_metadata.chapter_dir("9.8.1"), "u09")

    def test_expected_lines_must_be_observed_lines(self):
        found = self.check(self.make(expected="UT: one\nplain\n"))
        self.assertIn("expected: line 2 does not begin with 'UT: '", found)

    def test_comment_rules(self):
        found = self.check(self.make(body="// " + "x" * 80 + "\n// Verilator does this"))
        self.assertTrue(any(p.startswith("width:") for p in found), found)
        self.assertTrue(any(p.startswith("verilator:") for p in found), found)

    def test_initialized_block_locals_need_an_explicit_lifetime(self):
        found = self.check(self.make(body="module m; initial begin int value = 1; end endmodule"))
        self.assertTrue(any(p.startswith("lifetime:") and "value" in p for p in found), found)
        fixed = self.make(name="test_automatic", body=
                          "module m; initial begin automatic int value = 1; end endmodule")
        self.assertEqual(self.check(fixed), [])


if __name__ == "__main__":
    unittest.main()
