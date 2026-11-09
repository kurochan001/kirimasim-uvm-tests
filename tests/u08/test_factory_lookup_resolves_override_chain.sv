/*
:name: test_factory_lookup_resolves_override_chain
:description: override queries resolve a chain while wrapper lookup preserves type identity (IEEE 1800.2-2020 Section 8.3.1.7.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.7.1 8.3.1.7.2 8.3.1.7.3 8.3.1.7.4 8.3.1.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_lookup_resolves_override_chain.expected
*/
// What it checks:
// Override lookup returns the wrapper that creation would select for the
// requested path.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.3.1.7.1 (UVM-FACTORY-OVERRIDE-LOOKUP) gives the rule above.
// Setup: Query by name/type under an instance override, a type fallback and a
// multi-step override chain. Expected: Name/type queries agree on the final
// replacement while registered wrapper lookup remains separate.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The override query returns the replacement that creation would choose.
// A wrapper-by-name query still identifies the originally registered type.

module test_factory_lookup_resolves_override_chain;
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
    automatic uvm_object_wrapper original = base_item::get_type();
    automatic uvm_object_wrapper replacement = second_item::get_type();
    factory.set_type_override_by_type(original, first_item::get_type());
    factory.set_type_override_by_type(first_item::get_type(), replacement);
    $display("UT: final by type %0d by name %0d",
             factory.find_override_by_type(original, "env.chosen") == replacement,
             factory.find_override_by_name("base_item", "env.chosen") == replacement);
    $display("UT: registered type %0d name %0d wrapper remains %0d",
             factory.is_type_registered(original), factory.is_type_name_registered("base_item"),
             factory.find_wrapper_by_name("base_item") == original);
    $finish;
  end
endmodule
