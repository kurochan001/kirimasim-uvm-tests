/*
:name: test_object_registry_type_override_forwards_replace_flag
:description: object registry type overrides preserve or replace an installed override as requested (IEEE 1800.2-2020 Section 8.2.4.2.5)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.4.2.5 8.2.4.2.4 8.3.1.4.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_registry_type_override_forwards_replace_flag.expected
*/
// What it checks:
// The object registry type-override helper forwards replacement control to the
// factory.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.2.4.2.5 (UVM-REGISTRY-OBJECT-TYPE-OVERRIDE) gives the rule
// above. Setup: Install a first override, retain it with replace zero, then
// replace it with replace one. Expected: Creation first retains
// first_item/first_env, then selects second_item/second_env as applicable.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Exercise the registry convenience method with both replace values.
// The created dynamic types expose the factory configuration it forwards.

module test_object_registry_type_override_forwards_replace_flag;
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
    base_item retained;
    base_item replaced;
    base_item::type_id::set_type_override(first_item::get_type());
    base_item::type_id::set_type_override(second_item::get_type(), 0);
    retained = base_item::type_id::create("retained");
    base_item::type_id::set_type_override(second_item::get_type(), 1);
    replaced = base_item::type_id::create("replaced");
    $display("UT: retained %s replaced %s", retained.get_type_name(), replaced.get_type_name());
    $finish;
  end
endmodule
