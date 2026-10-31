/*
:name: test_object_wrapper_follows_dynamic_type
:description: a base handle retains the derived object type and wrapper (IEEE 1800.2-2020 Section 5.3.4.5)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.4.5 5.3.4.6 5.3.4.7 8.2.4.2.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_wrapper_follows_dynamic_type.expected
*/
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
    first_item derived_value = new;
    base_item base_handle = derived_value;
    uvm_object_wrapper base_type = base_item::get_type();
    uvm_object_wrapper derived_type = first_item::get_type();
    $display("UT: wrappers distinct %0d", base_type != derived_type);
    $display("UT: dynamic wrapper %0d", base_handle.get_object_type() == first_item::get_type());
    $display("UT: dynamic name %s", base_handle.get_type_name());
    $finish;
  end
endmodule
