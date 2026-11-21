"""Checks of tools/api_census.py that need no slang: reading the library's
marks and building the two lists."""

from pathlib import Path
import unittest
from unittest import mock

import api_census

LIBRARY = """// @uvm-ieee 1800.2-2020 auto 5.1
virtual class base_thing extends uvm_void;
  // @uvm-ieee 1800.2-2020 auto 5.1.1
  extern function new(string name = "");
  // @uvm-ieee 1800.2-2020 manual 5.1.2
  pure virtual function
  int get_count(int unsigned index);
  extern virtual function uvm_reg_data_t
        // @uvm-ieee 1800.2-2020 auto 5.1.3
        get_reset(string kind = "HARD");
  // @uvm-ieee 1800.2-2020 auto 5.1.4
  virtual task wait_for(input bit [3:0] value);
  endtask
  // @uvm-ieee 1800.2-2020 auto 5.1.5
  `uvm_object_utils(base_thing)
endclass
// @uvm-ieee 1800.2-2020 auto 5.2
function void base_thing::do_print(uvm_printer printer);
endfunction
typedef uvm_config_db#(string) uvm_config_string /* @uvm-ieee 1800.2-2020 auto C.4 */ ;
// @uvm-ieee 1800.2-2020 auto F.2
typedef enum bit [1:0] {
  ONE,
  TWO
} small_e;
// @uvm-ieee 1800.2-2020 auto B.1
`define uvm_thing(ARG) \\
  ARG
// @uvm-ieee 1800.2-2020 auto B.2
`ifndef UVM_LIMIT
 `define UVM_LIMIT 4
`endif
"""


class Census(unittest.TestCase):
    def test_each_mark_gives_its_declaration(self):
        found = api_census.parse_file(LIBRARY, "src/x.svh")
        self.assertEqual(
            [(d["kind"], api_census.key(d) if d["name"] else None, d["clause"]) for d in found],
            [("class", "base_thing", "5.1"), ("function", "base_thing::new", "5.1.1"),
             ("function", "base_thing::get_count", "5.1.2"),
             ("function", "base_thing::get_reset", "5.1.3"),
             ("task", "base_thing::wait_for", "5.1.4"), ("other", None, "5.1.5"),
             ("function", "base_thing::do_print", "5.2"),
             ("typedef", "uvm_config_string", "C.4"), ("typedef", "small_e", "F.2"),
             ("macro", "uvm_thing", "B.1"), ("macro", "UVM_LIMIT", "B.2")])
        self.assertEqual(found[2]["mode"], "manual")

    def test_a_hierarchical_path_gives_class_and_name(self):
        self.assertEqual(api_census.routine_key("uvm_pkg::uvm_tlm_fifo#(int)::get"),
                         "uvm_tlm_fifo::get")
        self.assertEqual(api_census.routine_key(
            'uvm_pkg::uvm_component_registry#(t,"a::b")::create'), "uvm_component_registry::create")
        self.assertEqual(api_census.routine_key("uvm_pkg::run_test"), "run_test")
        self.assertIsNone(api_census.routine_key("test_a.driver::put"))

    def test_the_lists_separate_unused_from_named_only(self):
        def row(kind, name, using, naming):
            return {"kind": kind, "name": name, "scope": None, "clause": "5.1", "file": "src/x.svh",
                    "tests_using": using, "tests_naming": naming}
        unused, name_only = api_census.lists([
            row("function", "called", 3, 3), row("function", "never", 0, 0),
            row("task", "through_a_port", 0, 2), row("macro", "uvm_unused", 0, 0),
            row("class", "unseen_class", 0, 0)])
        self.assertEqual([i["name"] for i in unused], ["never", "uvm_unused"])
        self.assertEqual([i["name"] for i in name_only], ["through_a_port"])

    def test_a_class_and_a_macro_of_one_name_are_counted_apart(self):
        def mark(kind, name, scope=None):
            return {"kind": kind, "name": name, "scope": scope, "clause": "8.2", "file": "src/x.svh"}
        marks = [mark("class", "uvm_registry"), mark("macro", "uvm_registry"),
                 mark("function", "create", "uvm_registry"),
                 mark("function", "create", "uvm_registry"), mark("task", "never")]
        results = {"u05/a": (["uvm_registry::create", "uvm_registry::create"],
                             "uvm_registry r; `uvm_registry(x)"),
                   "u05/b": (["other::create"], "uvm_registry r; create();")}
        with (mock.patch.object(api_census, "declarations", return_value=marks),
              mock.patch.object(api_census.slang_elaborate, "load", return_value={"options": []}),
              mock.patch.object(api_census.suite_results, "find_tests", return_value=list(results)),
              mock.patch.object(api_census.suite_results, "test_id", side_effect=lambda t: t),
              mock.patch.object(api_census, "one_test",
                                side_effect=lambda n, o, r: (n, *results[n]))):
            rows = {(r["kind"], api_census.key(r)): r for r in api_census.census(1, Path("."))}
        self.assertEqual(len(rows), 4)
        self.assertEqual(rows["class", "uvm_registry"]["tests_using"], 2)
        self.assertEqual(rows["macro", "uvm_registry"]["tests_using"], 1)
        self.assertEqual(rows["class", "uvm_registry"]["tests_naming"], 2)
        self.assertEqual(rows["function", "uvm_registry::create"]["tests_using"], 1)
        self.assertEqual(rows["function", "uvm_registry::create"]["tests_naming"], 1)
        self.assertEqual(rows["task", "never"]["tests_using"], 0)

    def test_a_slang_process_that_fails_gives_no_census(self):
        def child(code, out):
            return mock.Mock(returncode=code, stdout=out, stderr="boom")
        with mock.patch.object(api_census, "own_code", return_value="code"):
            for done in (child(-11, ""), child(1, "[]"), child(0, ""), child(0, "{}")):
                with mock.patch.object(api_census.subprocess, "run", return_value=done):
                    with self.assertRaises(api_census.CensusError):
                        api_census.one_test("u05/x", [], Path("."))
            with mock.patch.object(api_census.subprocess, "run",
                                   return_value=child(0, 'note\n["a::b"]\n')):
                self.assertEqual(api_census.one_test("u05/x", [], Path(".")),
                                 ("u05/x", ["a::b"], "code"))
            with mock.patch.object(api_census.subprocess, "run", return_value=child(0, "null\n")):
                self.assertEqual(api_census.one_test("u05/x", [], Path(".")), ("u05/x", [], "code"))


if __name__ == "__main__":
    unittest.main()
