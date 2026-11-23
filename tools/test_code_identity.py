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
:files: helpers/h.svh helpers/lines.svh
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
"""
LINES = """initial begin
  a = 1; expected_line = `__LINE__ + 1;
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
        self.write("tests/u05/helpers/lines.svh", LINES)
        self.write("tools/bridge.cpp", "int bridge;\n")
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

    def test_a_space_inside_a_time_literal_or_an_operator_changes_the_tokens(self):
        for joined, apart in (("#1ns x;", "#1 ns x;"), ("##1step", "##1 step"), ("#2.5ps", "#2.5 ps"),
                              ("x dist {1 := 2}", "x dist {1 : = 2}"), ("m u(.*);", "m u(. *);"),
                              ("a |=> b", "a | => b"), ("(a => b) = 1", "(a = > b) = 1"),
                              ("{1 :/ 2}", "{1 : / 2}"), ("(* full_case *)", "( * full_case * )")):
            self.assertNotEqual(code_identity.tokens(joined), code_identity.tokens(apart), joined)
        for same, other in (("#1ns  x;", "#1ns x;"), ("a = b+1;", "a = b + 1;"),
                            ("int ns = 3;", "int ns  =  3;")):
            self.assertEqual(code_identity.tokens(same), code_identity.tokens(other), same)

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

    def test_retag_allows_only_the_simulator_tags_of_the_oracle_fields(self):
        for old, new in ((":oracle: spec verilator@5.052", ":oracle: spec verilator@5.054"),
                         (":oracle: spec verilator@5.052", ":oracle: spec")):
            self.edit("tests/u05/test_a.sv", old, new)
            self.rejects("metadata fields differ")
            self.assertEqual(code_identity.check(self.base, retag=True), ["tests/u05/test_a.sv"])
            self.git("checkout", "--", ".")
        for old, new in ((":oracle: spec verilator@5.052", ":oracle: verilator@5.054"),
                         (":type: simulation", ":type: elaboration")):
            self.edit("tests/u05/test_a.sv", old, new)
            with self.assertRaisesRegex(code_identity.IdentityError, "metadata fields differ"):
                code_identity.check(self.base, retag=True)
            self.git("checkout", "--", ".")
        self.edit("tests/u05/test_a.sv", ":oracle: spec verilator@5.052", ":oracle: spec")
        record = self.root / "ghost.json"
        record.write_text(json.dumps({"simulator": "ghost", "tests": {
            "u05/test_a": {"inputs_sha256": self.digest}}}))
        self.assertEqual(code_identity.carry(self.base, record, record, retag=True), 1)
        carried = json.loads(record.read_text())
        self.assertEqual(carried["tests"]["u05/test_a"]["carried_from"], self.digest)
        self.assertIn("simulator tags", carried["carried_forward"][0]["rule"])

    def test_retag_requires_a_guest_record_before_carrying_results(self):
        self.edit("tests/u05/test_a.sv", "verilator@5.052", "verilator@5.054")
        record = self.root / "results.json"
        for simulator in ("verilator", "verilator_cmdline", "verilator_hdl", "verilator_regex",
                          None):
            with self.subTest(simulator=simulator):
                data = {"tests": {"u05/test_a": {"status": "pass", "inputs_sha256": self.digest}}}
                if simulator is not None:
                    data["simulator"] = simulator
                record.write_text(json.dumps(data))
                with self.assertRaisesRegex(code_identity.IdentityError, "retag"):
                    code_identity.carry(self.base, record, record, retag=True)
                self.assertEqual(json.loads(record.read_text()), data)

    def test_retag_leaves_the_other_words_and_fields_pinned(self):
        # `verilator@` without a release is not a simulator tag word, and a
        # tag-looking word outside the oracle fields stays an ordinary word.
        for old, new in ((":oracle: spec verilator@5.052", ":oracle: spec verilator@"),
                         (":name: test_a", ":name: test_a verilator@5.054")):
            self.edit("tests/u05/test_a.sv", old, new)
            with self.assertRaisesRegex(code_identity.IdentityError, "metadata fields differ"):
                code_identity.check(self.base, retag=True)
            self.git("checkout", "--", ".")
        self.edit("tests/u05/test_a.sv", ":oracle: spec verilator@5.052", ":oracle: spec")
        record = self.root / "ghost.json"
        record.write_text(json.dumps({"tests": {"u05/test_a": {"inputs_sha256": self.digest}}}))
        with self.assertRaisesRegex(code_identity.IdentityError, "metadata fields differ"):
            code_identity.carry(self.base, record, record)
        self.git("checkout", "--", ".")

    def test_refresh_moves_the_recorded_fingerprints_of_a_retag_edit(self):
        self.edit("tests/u05/test_a.sv", "verilator@5.052", "verilator@5.054")
        with self.assertRaisesRegex(code_identity.IdentityError, "metadata fields differ"):
            code_identity.refresh(self.base)
        moved = code_identity.refresh(self.base, retag=True)
        self.assertEqual(moved, {"coverage/test_index.json": 1, "coverage/known_causes.json": 1})
        current = suite_results.input_digest(self.root / "tests/u05/test_a.sv")
        index = json.loads((self.root / "coverage/test_index.json").read_text())
        self.assertEqual(index["tests"]["u05/test_a"]["inputs_sha256"], current)
        causes = json.loads((self.root / "coverage/known_causes.json").read_text())
        self.assertEqual(causes["causes"][0]["inputs_sha256"], current)

    def test_a_file_that_uses_the_line_macro_keeps_its_line_layout(self):
        for old, new in (("`__LINE__ + 1;\n", "`__LINE__ + 1;\n  // between\n"),
                         ("  a = 1; expected", "  a = 1;\n  expected"),
                         ("initial begin\n", "initial begin\n  // inside\n")):
            self.edit("tests/u05/helpers/lines.svh", old, new)
            self.rejects("line distances around `__LINE__ differ")
            self.git("checkout", "--", ".")
        self.edit("tests/u05/helpers/lines.svh", "initial begin\n", "// above\ninitial begin\n")
        code_identity.check(self.base)

    def test_metacomments_keep_their_place_and_macro_arguments_their_text(self):
        self.write("tests/u05/helpers/h.svh", HELPER + "logic a /*verilator public*/; logic b;\n"
                   "`uvm_object_param_utils(my_t#(int))\n")
        self.git("add", "-A")
        self.git("-c", "user.name=t", "-c", "user.email=t@example.com", "commit", "-qm", "more")
        self.base = self.git("rev-parse", "HEAD").strip()
        self.edit("tests/u05/helpers/h.svh", "logic a /*verilator public*/; logic b;",
                  "logic a; logic b /*verilator public*/;")
        self.rejects("tokens differ")
        self.git("checkout", "--", ".")
        self.edit("tests/u05/helpers/h.svh", "my_t#(int)", "my_t #( int )")
        self.rejects("the text of a macro's arguments differs")

    def test_directive_edge_cases_and_unicode_spaces_are_rejected(self):
        self.edit("tests/u05/helpers/h.svh", "((x) * \\\n", "((x) * \\ \n")
        self.rejects("compiler-directive lines differ")
        self.git("checkout", "--", ".")
        self.edit("tests/u05/helpers/h.svh", "class h;", "class\u3000h;")
        self.rejects("tokens differ")

    def test_comments_and_quoted_parentheses_do_not_end_macro_arguments(self):
        for body in ('x /* ) */ + y', '"a)" + y', r'"a\\" + y'):
            old = f'module t; initial $display(`SHOW({body})); endmodule'
            changed = old.replace(" + y", "  + y")
            with self.subTest(body=body):
                self.assertIn("the text of a macro's arguments differs",
                              code_identity.source_problems(old.encode(), changed.encode()))

    def test_a_changed_input_outside_tests_stops_the_move(self):
        self.write("tests/u05/test_a.sv", TEST.replace(":files:", ":dpi_c: @../../tools/bridge.cpp\n:files:"))
        self.git("add", "-A")
        self.git("-c", "user.name=t", "-c", "user.email=t@example.com", "commit", "-qm", "dpi")
        self.base = self.git("rev-parse", "HEAD").strip()
        digest = suite_results.input_digest(self.root / "tests/u05/test_a.sv")
        self.write("coverage/test_index.json", json.dumps({"schema_version": 1, "tests": {
            "u05/test_a": {"primary_clause": "5.1", "inputs_sha256": digest}}}))
        self.readable()
        self.write("tools/bridge.cpp", "int bridge = 1;\n")
        with self.assertRaisesRegex(code_identity.IdentityError, "outside tests/ changed"):
            code_identity.refresh(self.base)

    def test_added_or_changed_non_source_files_are_rejected(self):
        self.write("tests/u05/helpers/new.svh", "\n")
        self.rejects("added")
        (self.root / "tests/u05/helpers/new.svh").unlink()
        self.edit("tests/u05/test_a.expected", "UT: 3", "UT: 4")
        self.rejects("not a source, but its bytes differ")

    def test_a_removed_library_lock_stops_the_move(self):
        (self.root / "third_party/uvm.lock").unlink()
        with self.assertRaisesRegex(code_identity.IdentityError, "outside tests/ changed"):
            code_identity.refresh(self.base)

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

    def test_refresh_validates_both_records_before_updating_the_index(self):
        self.readable()
        index = self.root / "coverage/test_index.json"
        before = index.read_bytes()
        self.write("coverage/known_causes.json", "{")
        with self.assertRaises(json.JSONDecodeError):
            code_identity.refresh(self.base)
        self.assertEqual(index.read_bytes(), before)

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
