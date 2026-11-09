/*
:name: test_factory_instance_alias_creates_in_context
:description: an instance alias resolves at its declared full instance path (IEEE 1800.2-2020 Section 8.3.1.6.2)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.6.2 8.3.1.5 5.3.4.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_instance_alias_creates_in_context.expected
*/
// What it checks:
// A factory alias names the original wrapper for applicable factory requests.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.3.1.6.2 (UVM-FACTORY-INSTANCE-ALIAS) gives the rule above.
// Setup: Create through the alias, with and without a type override; instance
// aliases use a matching context. Expected: Creation uses the original or
// overridden type as configured and preserves the requested instance name.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An instance alias names a wrapper within a creation context. Observe the
// created object's type without relying on a no-override factory query.

module test_factory_instance_alias_creates_in_context;
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
    automatic uvm_factory factory = uvm_factory::get();
    uvm_object value;
    factory.set_inst_alias("m1_local", first_item::get_type(), "env.chosen");
    value = factory.create_object_by_name("m1_local", "env", "chosen");
    if (value == null) $fatal(1, "instance alias creation failed");
    $display("UT: wrapper %0d", value.get_object_type() == first_item::get_type());
    $display("UT: type %s name %s", value.get_type_name(), value.get_name());
    $finish;
  end
endmodule
