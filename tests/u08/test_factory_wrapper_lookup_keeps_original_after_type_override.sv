/*
:name: test_factory_wrapper_lookup_keeps_original_after_type_override
:description: wrapper lookup returns the registered proxy while creation follows a type override (IEEE 1800.2-2020 Section 8.3.1.7.2)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.7.2 8.3.1.7.1 8.3.1.3 8.3.1.4.2 8.3.1.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_wrapper_lookup_keeps_original_after_type_override.expected
*/
// What it checks:
// Registered-name lookup returns the wrapper associated with that name rather
// than resolving creation overrides.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.3.1.7.2 (UVM-FACTORY-WRAPPER-NAME-LOOKUP) gives the rule
// above. Setup: Query exact object/component names and retain their original
// registrations after a type override. Expected: The original wrapper remains
// identifiable and distinct from the replacement wrapper.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Separate registered-name lookup from override resolution. Install
// an override explicitly before querying the type that creation selects.

module test_factory_wrapper_lookup_keeps_original_after_type_override;
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
    automatic uvm_default_factory factory = new;
    automatic uvm_object_wrapper base_type = base_item::get_type();
    automatic uvm_object_wrapper replacement_type = replacement_item::get_type();
    uvm_object created;
    factory.register(base_type);
    factory.register(replacement_type);
    factory.set_type_override_by_type(base_type, replacement_type);
    $display("UT: original_wrapper %0d replacement_wrapper %0d",
        factory.find_wrapper_by_name("base_item") == base_type,
             factory.find_wrapper_by_name("replacement_item") == replacement_type);
    $display("UT: resolved_override %0d", factory.find_override_by_type(base_type,
        "created") == replacement_type);
    created = factory.create_object_by_name("base_item", "", "created");
    if (created == null) $fatal(1, "object not created");
    $display("UT: created type %s name %s", created.get_type_name(), created.get_name());
    $finish;
  end
endmodule
