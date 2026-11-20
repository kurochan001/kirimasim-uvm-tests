"""Checks of tools/api_census.py that need no slang: reading the library's
marks and building the two lists."""

import unittest

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


if __name__ == "__main__":
    unittest.main()
