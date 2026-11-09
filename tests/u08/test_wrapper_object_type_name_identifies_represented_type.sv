/*
:name: test_wrapper_object_type_name_identifies_represented_type
:description: object wrapper type names identify the represented types independently of overrides (IEEE 1800.2-2020 Section 8.3.2.2.3)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.2.2.3 8.2.4.2.2 8.3.1.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_wrapper_object_type_name_identifies_represented_type.expected
*/
// What it checks:
// A wrapper type-name query identifies its represented type.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.3.2.2.3 (UVM-WRAPPER-TYPE-NAME) gives the rule above. Setup:
// Inspect object/component wrappers before and after setting a creation
// override. Expected: Each wrapper keeps its original type name despite the
// creation override.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Read type names through common wrapper handles before and after
// an override. A creation override does not change either proxy identity.

module test_wrapper_object_type_name_identifies_represented_type;
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
    automatic uvm_factory factory = uvm_factory::get();
    automatic uvm_object_wrapper original = item::get_type();
    automatic uvm_object_wrapper replacement = replacement_item::get_type();
    $display("UT: before %s %s", original.get_type_name(), replacement.get_type_name());
    factory.set_type_override_by_type(original, replacement);
    $display("UT: after %s %s", original.get_type_name(), replacement.get_type_name());
    $finish;
  end
endmodule
