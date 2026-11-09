/*
:name: test_object_registry_explicit_context_supersedes_parent
:description: an explicit object registry context supersedes the parent context (IEEE 1800.2-2020 Section 8.2.4.2.4)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.4.2.4 8.3.1.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_registry_explicit_context_supersedes_parent.expected
*/
// What it checks:
// Object registry creation uses an explicit context when supplied, otherwise
// the parent context.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.2.4.2.4 (UVM-REGISTRY-OBJECT-CREATE-CONTEXT) gives the rule
// above. Setup: Install distinct instance overrides for the parent-derived and
// explicit paths. Expected: The selected replacement follows the chosen
// context while the plain object retains its leaf name.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Two exact instance overrides distinguish the parent-derived context
// from the explicit context. The registry must select the explicit context.

module test_object_registry_explicit_context_supersedes_parent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class context_component extends uvm_component;
    `uvm_component_utils(context_component)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass

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
    automatic context_component parent = new("env", null);
    automatic uvm_factory factory = uvm_factory::get();
    base_item value;
    factory.set_inst_override_by_type(base_item::get_type(), first_item::get_type(), "env.item");
    factory.set_inst_override_by_type(base_item::get_type(), second_item::get_type(), "other.item");
    value = base_item::type_id::create("item", parent, "other");
    $display("UT: type %s name %s", value.get_type_name(), value.get_name());
    $finish;
  end
endmodule
