"""Checks of tools/code_identity.py on a small git repository."""

import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

import code_identity
import suite_results

TEST = """/*
:name: test_a
:type: simulation
:oracle: spec verilator@5.052
:files: helpers/h.svh
:expected_stdout: @test_a.expected
*/
module test_a;
  `include "h.svh"
  initial begin a = 1; b = 2; $display("UT: %0d // not a comment", a + b); end
endmodule
"""
HELPER = """`define TWICE(x) ((x) * \\
  2)
class h; int n; function void f(); n = 1; n++; endfunction endclass
initial begin
  expected_line = `__LINE__ + 1;
  `uvm_info("id", "msg", UVM_LOW)
end
"""


class CodeIdentity(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name).resolve()
        for module in (code_identity, suite_results):
            patch = mock.patch.object(module, "ROOT", self.root)
            patch.start()
            self.addCleanup(patch.stop)
        self.write("third_party/uvm.lock", json.dumps({"version": "9.9"}))
        self.write("tests/u05/test_a.sv", TEST)
        self.write("tests/u05/test_a.expected", "UT: 3 // not a comment\n")
        self.write("tests/u05/helpers/h.svh", HELPER)
        self.digest = suite_results.input_digest(self.root / "tests/u05/test_a.sv")
        self.write("coverage/test_index.json", json.dumps({"schema_version": 1, "tests": {
            "u05/test_a": {"primary_clause": "5.1", "inputs_sha256": self.digest}}}))
        self.write("coverage/known_causes.json", json.dumps({"causes": [
            {"test": "u05/test_a", "inputs_sha256": self.digest}]}))
        self.git("init", "-q")
        self.git("add", "-A")
        self.git("-c", "user.name=t", "-c", "user.email=t@example.com", "commit", "-qm", "base")
        self.base = self.git("rev-parse", "HEAD").strip()

    def git(self, *args):
        return subprocess.run(["git", *args], cwd=self.root, check=True, capture_output=True,
                              text=True).stdout

    def write(self, name, text):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def edit(self, name, old, new):
        path = self.root / name
        text = path.read_text()
        self.assertIn(old, text)
        path.write_text(text.replace(old, new, 1))

    def rejects(self, message):
        with self.assertRaisesRegex(code_identity.IdentityError, message):
            code_identity.check(self.base)

    def readable(self):
        """The kind of edit item 8 makes: comments and one statement per line."""
        self.edit("tests/u05/test_a.sv", "*/\nmodule", "*/\n// What it checks: a sum.\nmodule")
        self.edit("tests/u05/test_a.sv", "initial begin a = 1; b = 2; $display",
                  "initial begin\n    a = 1;\n    b = 2;\n    $display")
        self.edit("tests/u05/helpers/h.svh", "function void f(); n = 1; n++; endfunction",
                  "function void f();\n  n = 1;\n  n++;\nendfunction")

    def test_comments_and_line_breaks_keep_the_code(self):
        self.readable()
        self.assertEqual(sorted(code_identity.check(self.base)),
                         ["tests/u05/helpers/h.svh", "tests/u05/test_a.sv"])

    def test_a_changed_token_is_rejected(self):
        self.edit("tests/u05/helpers/h.svh", "n++;", "n+=1;")
        self.rejects("tokens differ")
        self.git("checkout", "--", ".")
        self.edit("tests/u05/test_a.sv", '"UT: %0d // not a comment"', '"UT: %0d  // not a comment"')
        self.rejects("tokens differ")

    def test_header_directives_and_metacomments_are_kept(self):
        self.edit("tests/u05/test_a.sv", ":oracle: spec verilator@5.052", ":oracle: spec")
        self.rejects("metadata fields differ")
        self.git("checkout", "--", ".")
        self.edit("tests/u05/helpers/h.svh", "((x) * \\\n  2)", "((x) *\n  2)")
        self.rejects("compiler-directive lines differ")
        self.git("checkout", "--", ".")
        self.edit("tests/u05/test_a.sv", "module test_a;", "module test_a;\n  // verilator lint_off WIDTH")
        self.rejects("metacomments differ")

    def test_line_distance_to_line_macro_is_kept(self):
        self.edit("tests/u05/helpers/h.svh", "`__LINE__ + 1;\n", "`__LINE__ + 1;\n  // between\n")
        self.rejects("line distances around `__LINE__ differ")
        self.git("checkout", "--", ".")
        self.edit("tests/u05/helpers/h.svh", "initial begin\n", "// above\ninitial begin\n")
        code_identity.check(self.base)

    def test_added_or_changed_non_source_files_are_rejected(self):
        self.write("tests/u05/helpers/new.svh", "\n")
        self.rejects("added")
        (self.root / "tests/u05/helpers/new.svh").unlink()
        self.edit("tests/u05/test_a.expected", "UT: 3", "UT: 4")
        self.rejects("not a source, but its bytes differ")

    def test_refresh_moves_fingerprints_recorded_at_the_base(self):
        self.readable()
        moved = code_identity.refresh(self.base)
        self.assertEqual(moved, {"coverage/test_index.json": 1, "coverage/known_causes.json": 1})
        current = suite_results.input_digest(self.root / "tests/u05/test_a.sv")
        self.assertNotEqual(current, self.digest)
        index = json.loads((self.root / "coverage/test_index.json").read_text())
        self.assertEqual(index["tests"]["u05/test_a"]["inputs_sha256"], current)
        causes = json.loads((self.root / "coverage/known_causes.json").read_text())
        self.assertEqual(causes["causes"][0]["inputs_sha256"], current)

    def test_refresh_refuses_a_code_change(self):
        self.edit("tests/u05/helpers/h.svh", "n = 1;", "n = 2;")
        with self.assertRaises(code_identity.IdentityError):
            code_identity.refresh(self.base)

    def test_carry_moves_only_records_made_at_the_base(self):
        self.readable()
        record = self.root / "guest.json"
        record.write_text(json.dumps({"simulator": "guest", "tests": {
            "u05/test_a": {"status": "fail", "inputs_sha256": self.digest},
            "u05/test_gone": {"status": "pass", "inputs_sha256": self.digest}}}))
        out = self.root / "carried.json"
        self.assertEqual(code_identity.carry(self.base, record, out), 1)
        data = json.loads(out.read_text())
        entry = data["tests"]["u05/test_a"]
        self.assertEqual(entry["carried_from"], self.digest)
        self.assertEqual(entry["inputs_sha256"],
                         suite_results.input_digest(self.root / "tests/u05/test_a.sv"))
        self.assertEqual(data["tests"]["u05/test_gone"]["inputs_sha256"], self.digest)
        self.assertEqual(data["carried_forward"][0]["records"], 1)
        self.assertEqual(data["carried_forward"][0]["base"], self.base)


if __name__ == "__main__":
    unittest.main()
