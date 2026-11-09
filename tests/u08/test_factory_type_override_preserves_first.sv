/*
:name: test_factory_type_override_preserves_first
:description: replace zero preserves an existing type override (IEEE 1800.2-2020 Section 8.3.1.4.2)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.4.2 8.3.1.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_type_override_preserves_first.expected
*/
// What it checks:
// An existing type override remains intact when a later registration disables
// replacement.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.3.1.4.2 (UVM-FACTORY-PRESERVE-OVERRIDE) gives the rule above.
// Setup: Install first_item, then attempt another override with replace zero.
// Expected: Creation still returns first_item with the requested name.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A type override selects the replacement for a creation request.
// Registering a later override with replace zero keeps the earlier one.

module test_factory_type_override_preserves_first;
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
class second_item extends base_item;
  `uvm_object_utils(second_item)
  function new(string name="second_item"); super.new(name); endfunction
endclass

initial begin
  automatic uvm_factory factory = uvm_factory::get();
  uvm_object item;
  factory.set_type_override_by_type(base_item::get_type(), first_item::get_type());
  factory.set_type_override_by_type(base_item::get_type(), second_item::get_type(), 0);
  item = factory.create_object_by_type(base_item::get_type(), "", "chosen");
  $display("UT: type %s name %s", item.get_type_name(), item.get_name());
  $finish;
end
endmodule
