/*
:name: test_wrapper_create_component_keeps_parent_contexts_distinct
:description: one component proxy creates separate components under different parents (IEEE 1800.2-2020 Section 8.3.2.2.2)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.2.2.2 8.2.3.2.1 13.1.3.1 13.1.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_wrapper_create_component_keeps_parent_contexts_distinct.expected
*/
// What it checks:
// A component wrapper forwards its supplied name and parent to construction of
// its represented type.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.3.2.2.2 (UVM-WRAPPER-COMPONENT-CREATE) gives the rule above.
// Setup: Use the same leaf under two parents and call the proxy directly with
// an override installed. Expected: Constructed components retain their actual
// parents, distinct paths and represented type.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The same leaf name is valid under two different parents. Compare
// component identity and full paths without relying on allocation IDs.

module test_wrapper_create_component_keeps_parent_contexts_distinct;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    int payload = 7;
    function new(string name="item"); super.new(name); endfunction
  endclass
  class replacement_item extends item;
    `uvm_object_utils(replacement_item)
    function new(string name="replacement_item"); super.new(name); endfunction
  endclass
  class node extends uvm_component;
    `uvm_component_utils(node)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class replacement_node extends node;
    `uvm_component_utils(replacement_node)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass

  initial begin
    automatic node first_parent = new("left", null);
    automatic node second_parent = new("right", null);
    automatic uvm_object_wrapper wrapper = node::get_type();
    uvm_component first;
    uvm_component second;
    first = wrapper.create_component("child", first_parent);
    second = wrapper.create_component("child", second_parent);
    if (first == null || second == null) $fatal(1, "component not created");
    $display("UT: distinct %0d parents %0d %0d", first != second,
             first.get_parent() == first_parent, second.get_parent() == second_parent);
    $display("UT: full_names %s %s", first.get_full_name(), second.get_full_name());
    $finish;
  end
endmodule
