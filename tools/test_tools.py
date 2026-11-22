"""Unit tests of the tools: the observed lines, the UVM macros, the library
digest, the tool versions, the runner fingerprint and the metadata checks."""

import hashlib
import io
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path
from unittest import mock

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
{exit}{extra}:expected_stdout: @{name}.expected
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
             extra="", body="", expected="UT: one\n", no_exit=False):
        path = self.root / folder / f"{name}.sv"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(HEADER.format(name=name, tags=tags, lrm=lrm, extra=extra, body=body,
                                      exit="" if "expected_exit" in extra or no_exit
                                      else ":expected_exit: 0\n"))
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

    def archive(self, members):
        data = io.BytesIO()
        with tarfile.open(fileobj=data, mode="w:gz") as archive:
            for name, text in members.items():
                info = tarfile.TarInfo(name)
                info.size = len(text)
                archive.addfile(info, io.BytesIO(text))
        return data.getvalue()

    def test_the_one_top_directory_of_the_archive_is_returned(self):
        top = fetch_uvm.extract(self.archive({"uvm-1.0/src/x.sv": b"one\n"}), self.root)
        self.assertEqual(top.name, "uvm-1.0")
        self.assertEqual((top / "src/x.sv").read_bytes(), b"one\n")

    def test_an_archive_without_exactly_one_top_directory_is_refused(self):
        with self.assertRaisesRegex(ValueError, "one top directory"):
            fetch_uvm.extract(self.archive({"a/x": b"1", "b/y": b"2"}), self.root)
        with self.assertRaisesRegex(ValueError, "one top directory"):
            fetch_uvm.extract(self.archive({"x.sv": b"bare"}), self.root)

    def test_a_link_in_the_archive_is_refused(self):
        data = io.BytesIO()
        with tarfile.open(fileobj=data, mode="w:gz") as archive:
            info = tarfile.TarInfo("top/link")
            info.type = tarfile.SYMTYPE
            info.linkname = "/etc/passwd"
            archive.addfile(info)
        with self.assertRaisesRegex(ValueError, "unsafe"):
            fetch_uvm.extract(data.getvalue(), self.root)

    def test_the_check_says_why_a_copy_is_not_the_locked_release(self):
        tree = self.root / "third_party/uvm/1.0"
        (tree / "src").mkdir(parents=True)
        (tree / "src/x.sv").write_text("one\n")
        value, count = fetch_uvm.digest(tree)
        lock = {"content_sha256": value, "files": count, "version": "1.0"}
        with mock.patch.object(fetch_uvm, "ROOT", self.root):
            self.assertEqual(fetch_uvm.check(tree, lock), "")
            (tree / "src/x.sv").write_text("two\n")
            self.assertIn("differs from the lock", fetch_uvm.check(tree, lock))
            self.assertIn("is missing",
                          fetch_uvm.check(self.root / "third_party/uvm/9.9", lock))


class ToolVersion(Sample):
    def test_the_first_line_of_stdout_is_the_version(self):
        out = "Verilator 5.054 2026-11-01 rev v5.054\nSecond line\n"
        with mock.patch.object(suite_results.subprocess, "run",
                               return_value=subprocess.CompletedProcess([], 0, out, "")):
            self.assertEqual(suite_results.tool_version(["verilator", "--version"]),
                             "Verilator 5.054 2026-11-01 rev v5.054")

    def test_stderr_serves_when_stdout_is_empty(self):
        with mock.patch.object(suite_results.subprocess, "run",
                               return_value=subprocess.CompletedProcess([], 0, "", "yosys 0.50\n")):
            self.assertEqual(suite_results.tool_version(["yosys", "--version"]), "yosys 0.50")

    def test_a_missing_or_hanging_tool_has_no_version(self):
        self.assertEqual(suite_results.tool_version(["no-such-tool-4f2a", "--version"]), "")
        with mock.patch.object(suite_results.subprocess, "run",
                               side_effect=subprocess.TimeoutExpired(["x"], 60)):
            self.assertEqual(suite_results.tool_version(["x", "--version"]), "")


class RunnerFingerprint(Sample):
    """The result evidence is bound to exactly the three files the policy names."""

    def setUp(self):
        super().setUp()
        for name in ("run_verilator.py", "suite_results.py", "uvm_common.py"):
            self.write(f"tools/{name}", "x = 1\n")
        self.write("tools/other_tool.py", "y = 1\n")

    def write(self, name, text):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def digest(self):
        with mock.patch.object(suite_results, "ROOT", self.root):
            return suite_results.runner_digest("verilator")

    def test_a_change_in_each_of_the_three_moves_the_fingerprint(self):
        base = self.digest()
        for name in ("run_verilator.py", "suite_results.py", "uvm_common.py"):
            with self.subTest(file=name):
                self.write(f"tools/{name}", "x = 2\n")
                self.assertNotEqual(self.digest(), base)
                self.write(f"tools/{name}", "x = 1\n")
        self.assertEqual(self.digest(), base)

    def test_the_fingerprint_is_the_names_and_bytes_of_exactly_those_files(self):
        moved = hashlib.sha256()
        for name in ("run_verilator.py", "suite_results.py", "uvm_common.py"):
            moved.update(name.encode() + b"\0")
            moved.update(b"x = 1\n")
        self.assertEqual(self.digest(), moved.hexdigest())
        self.write("tools/other_tool.py", "y = 2\n")
        self.assertEqual(self.digest(), moved.hexdigest())


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

    def test_a_simulation_test_states_its_exit_code(self):
        found = self.check(self.make(no_exit=True))
        self.assertTrue(any(p.startswith("exit:") for p in found), found)
        self.assertEqual(self.check(self.make(name="test_nonzero",
                                              extra=":expected_exit: nonzero\n")), [])
        for n, bad in enumerate(("", "abc", "0x1", "Nonzero", "0 1", "-1", "256", "01")):
            found = self.check(self.make(name=f"test_bad_exit{n}",
                                         extra=f":expected_exit: {bad}\n"))
            self.assertTrue(any("from 0 to 255" in p for p in found), (bad, found))
        self.assertEqual(self.check(self.make(name="test_code",
                                              extra=":expected_exit: 255\n")), [])

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
