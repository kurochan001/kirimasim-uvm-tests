/*
:name: test_object_wrapper_follows_dynamic_type
:description: a base handle retains the derived object type and wrapper (IEEE 1800.2-2020 Section 5.3.4.5)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.4.5 5.3.4.6 5.3.4.7 8.2.4.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_wrapper_follows_dynamic_type.expected
*/
// What it checks:
// The virtual object type query identifies the allocated object type proxy.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.3.4.6 (UVM-OBJECT-DYNAMIC-TYPE-PROXY) gives the rule above.
// Setup: Query registered base/derived objects through static and base
// handles. Expected: Object and matching static wrappers agree, while base and
// derived wrappers differ.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The virtual type query follows the allocated object. The base class
// static wrapper remains distinct from the derived class static wrapper.

module test_object_wrapper_follows_dynamic_type;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class base_item extends uvm_object;
    `uvm_object_utils(base_item)
    function new(string name="base_item"); super.new(name); endfunction
  endclass
  class first_item extends base_item;
    `uvm_object_utils(first_item)
    function new(string name="first_item"); super.new(name); endfunction
  endclass
  class second_item extends first_item;
    `uvm_object_utils(second_item)
    function new(string name="second_item"); super.new(name); endfunction
  endclass

  initial begin
    automatic first_item derived_value = new;
    automatic base_item base_handle = derived_value;
    automatic uvm_object_wrapper base_type = base_item::get_type();
    automatic uvm_object_wrapper derived_type = first_item::get_type();
    $display("UT: wrappers distinct %0d", base_type != derived_type);
    $display("UT: dynamic wrapper %0d", base_handle.get_object_type() == first_item::get_type());
    $display("UT: dynamic name %s", base_handle.get_type_name());
    $finish;
  end
endmodule
