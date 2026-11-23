/*
:name: test_config_runtime_exact_and_wildcard_writes_replace_build_precedence_in_order
:description: Build-time hierarchy gives way to ordered runtime writes while typed keys and peer scopes stay independent (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_runtime_exact_and_wildcard_writes_replace_build_precedence_in_order.expected
*/
// Install integer and string defaults in the parent, then write lower-
// precedence integers during both child build callbacks. At runtime write an
// exact child integer, replace the family wildcard, and set the other child
// exactly. Observe both children and the typed string at every transition.
// The parent owns the runtime schedule so sibling callback order cannot
// determine the result.

module test_config_runtime_exact_and_wildcard_writes_replace_build_precedence_in_order;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class leaf extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_config_db #(int)::set(this, "", "setting", 12);
    endfunction
    function int number();
      int result;
      if (!uvm_config_db #(int)::get(this, "", "setting", result)) $fatal(1, "missing int");
      return result;
    endfunction
    function string label_text();
      string result;
      if (!uvm_config_db #(string)::get(this, "", "setting", result)) $fatal(1, "missing string");
      return result;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    leaf left, right;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_config_db #(int)::set(this, "*", "setting", 84);
      uvm_config_db #(string)::set(this, "*", "setting", "green");
      left = new("left", this);
      right = new("right", this);
    endfunction
    function void snapshot(string label_text);
      $display("UT: %s left %0d right %0d labels %s %s", label_text, left.number(), right.number(),
               left.label_text(), right.label_text());
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      snapshot("build");
      uvm_config_db #(int)::set(left, "", "setting", 17);
      snapshot("left write");
      uvm_config_db #(int)::set(this, "*", "setting", 29);
      snapshot("wildcard");
      uvm_config_db #(int)::set(right, "", "setting", 43);
      snapshot("right write");
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
endmodule
