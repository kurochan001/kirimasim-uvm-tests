/*
:name: test_object_static_and_dynamic_wrappers_agree
:description: an object and its class return the same registered wrapper (IEEE 1800.2-2020 Section 5.3.4.5)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.4.5 5.3.4.6 5.3.4.7 8.2.4.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_static_and_dynamic_wrappers_agree.expected
*/
// The registry supplies one wrapper for a type. Static and object queries
// identify that same type without depending on a wrapper address or name.

module test_object_static_and_dynamic_wrappers_agree;
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
    automatic base_item value = new;
    automatic uvm_object_wrapper static_type = base_item::get_type();
    $display("UT: same wrapper %0d", value.get_object_type() == static_type);
    $display("UT: type name %s", value.get_type_name());
    $finish;
  end
endmodule
