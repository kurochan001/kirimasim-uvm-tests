/*
:name: test_factory_inst_override_by_name_replaces_the_named_type_at_matching_paths
:description: an instance override by name replaces the named type, or an arbitrary string, only at a matching path (IEEE 1800.2-2020 Section 8.3.1.4.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.4.1 8.3.1.5 8.3.1.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_inst_override_by_name_replaces_the_named_type_at_matching_paths.expected
*/
// What it checks:
// 1. An instance override by name replaces the original type name at a path
//    that matches full_inst_path, with wildcards, and nowhere else.
// 2. The original type name may be an arbitrary string that names no
//    registered type.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 8.3.1.4.1 (UVM-FACTORY-INST-BY-NAME-PATH) gives rule 1. Setup:
//    register base_item, first_item and second_item, override base_item by
//    second_item at env.hit and by first_item at wild.*, and create base_item
//    by name (8.3.1.5) with the parent path and name of each request.
//    Expected: env.hit gives second_item, wild.any gives first_item, and
//    other.hit gives base_item.
// 2. 1800.2-2020 8.3.1.4.1 (UVM-FACTORY-INST-BY-NAME-ARBITRARY) gives rule 2.
//    Setup: override the string unregistered_name by first_item at env.any.
//    Expected: creating unregistered_name by name at env.any gives first_item.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The factory's own method is called; the registry's and the component's
// set_inst_override are not used.
module test_factory_inst_override_by_name_replaces_the_named_type_at_matching_paths;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class base_item extends uvm_object;
    `uvm_object_utils(base_item)
    function new(string name="base_item");
      super.new(name);
    endfunction
  endclass
  class first_item extends base_item;
    `uvm_object_utils(first_item)
    function new(string name="first_item");
      super.new(name);
    endfunction
  endclass
  class second_item extends base_item;
    `uvm_object_utils(second_item)
    function new(string name="second_item");
      super.new(name);
    endfunction
  endclass

  initial begin
    automatic uvm_factory factory = uvm_factory::get();
    uvm_object exact;
    uvm_object wild;
    uvm_object other;
    uvm_object arbitrary;
    factory.set_inst_override_by_name("base_item", "second_item", "env.hit");
    factory.set_inst_override_by_name("base_item", "first_item", "wild.*");
    factory.set_inst_override_by_name("unregistered_name", "first_item", "env.any");
    exact = factory.create_object_by_name("base_item", "env", "hit");
    wild = factory.create_object_by_name("base_item", "wild", "any");
    other = factory.create_object_by_name("base_item", "other", "hit");
    arbitrary = factory.create_object_by_name("unregistered_name", "env", "any");
    $display("UT: exact %s wild %s other %s", exact.get_type_name(), wild.get_type_name(),
             other.get_type_name());
    $display("UT: arbitrary %s", arbitrary == null ? "null" : arbitrary.get_type_name());
    $finish;
  end
endmodule
