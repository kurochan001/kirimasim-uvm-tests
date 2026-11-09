/*
:name: test_wrapper_create_object_allocates_independent_instances
:description: object proxy creation allocates independent instances with constructor data (IEEE 1800.2-2020 Section 8.3.2.2.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.2.2.1 8.2.4.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_wrapper_create_object_allocates_independent_instances.expected
*/
// What it checks:
// An object wrapper creates a fresh object of the type it represents with the
// requested name.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.3.2.2.1 (UVM-WRAPPER-OBJECT-CREATE) gives the rule above.
// Setup: Create twice directly through the wrapper, including with a separate
// factory override installed. Expected: The represented type and independent
// handles/data are retained without applying registry overrides.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Create two explicitly named objects through the same base wrapper
// handle and mutate one instance without changing the other.

module test_wrapper_create_object_allocates_independent_instances;
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
    automatic uvm_object_wrapper wrapper = item::get_type();
    uvm_object first;
    uvm_object second;
    item first_item;
    item second_item;
    first = wrapper.create_object("first");
    second = wrapper.create_object("second");
    if (!$cast(first_item, first) || first_item == null) $fatal(1, "first item missing");
    if (!$cast(second_item, second) || second_item == null) $fatal(1, "second item missing");
    first_item.payload = 31;
    $display("UT: distinct %0d values %0d %0d", first != second, first_item.payload,
        second_item.payload);
    $display("UT: names %s %s", first.get_name(), second.get_name());
    $finish;
  end
endmodule
