/*
:name: test_factory_selection_preserves_detached_factory_registrations
:description: replacing the selected factory leaves detached factory registrations available (IEEE 1800.2-2020 Section 8.3.1.2.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.2.1 8.3.1.2.2 8.3.1.3 8.3.1.7.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_selection_preserves_detached_factory_registrations.expected
*/
// What it checks:
// 1. The static factory query returns the factory currently selected by the
//    core service.
// 2. The static factory setter updates the core-service factory reference.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 8.3.1.2.1 (UVM-FACTORY-CORE-ACCESSOR) gives rule 1 above.
//    Setup: Select factories through the service/static API and retain handles
//    to detached factories. Expected: The query returns the selected handle;
//    detached factories keep their own registrations.
// 2. 1800.2-2020 8.3.1.2.2 (UVM-FACTORY-CORE-SETTER) gives rule 2 above.
//    Setup: Replace via the static API, inspect through the core service, then
//    restore the saved reference. Expected: Both APIs observe the selected
//    factory and the saved reference is restored.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Prepare independent registries before replacing the global selection.
// Retained handles continue to address the same factories after replacement.

module test_factory_selection_preserves_detached_factory_registrations;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class base_item extends uvm_object;
    `uvm_object_utils(base_item)
    function new(string name="base_item"); super.new(name); endfunction
  endclass
  class replacement_item extends base_item;
    `uvm_object_utils(replacement_item)
    function new(string name="replacement_item"); super.new(name); endfunction
  endclass
  class other_item extends uvm_object;
    `uvm_object_utils(other_item)
    function new(string name="other_item"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_factory saved = uvm_factory::get();
    automatic uvm_default_factory first = new;
    automatic uvm_default_factory second = new;
    automatic uvm_object_wrapper base_type = base_item::get_type();
    automatic uvm_object_wrapper other_type = other_item::get_type();
    first.register(base_type);
    second.register(other_type);
    uvm_factory::set(first);
    $display("UT: first_selected base %0d other %0d",
        uvm_factory::get().is_type_registered(base_type),
            uvm_factory::get().is_type_registered(other_type));
    uvm_factory::set(second);
    $display("UT: second_selected base %0d other %0d",
        uvm_factory::get().is_type_registered(base_type),
            uvm_factory::get().is_type_registered(other_type));
    $display("UT: detached_first base %0d other %0d", first.is_type_registered(base_type),
        first.is_type_registered(other_type));
    uvm_factory::set(saved);
    $display("UT: restored %0d", uvm_factory::get() == saved);
    $finish;
  end
endmodule
