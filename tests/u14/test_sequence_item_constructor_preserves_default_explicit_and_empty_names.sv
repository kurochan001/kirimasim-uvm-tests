/*
:name: test_sequence_item_constructor_preserves_default_explicit_and_empty_names
:description: sequence item construction distinguishes an omitted name from explicit and empty names (14.1.2.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_item_constructor_preserves_default_explicit_and_empty_names.expected
*/
// What it checks:
// 1. The sequence item constructor uses its specified default name when the
//    name argument is omitted.
// 2. The sequence item constructor preserves an explicitly supplied instance
//    name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.1.2.1 (UVM-SEQUENCE-ITEM-CONSTRUCTOR-DEFAULT-NAME) gives
//    rule 1 above. Setup: Independent instances are constructed with omitted
//    and explicit name arguments. Expected: The omitted-name instance has the
//    name uvm_sequence_item.
// 2. 1800.2-2020 14.1.2.1 (UVM-SEQUENCE-ITEM-CONSTRUCTOR-EXPLICIT-NAME) gives
//    rule 2 above. Setup: Independent instances are constructed with omitted
//    and explicit name arguments. Expected: The explicit name is named_item
//    and an explicitly empty name remains empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequence_item_constructor_preserves_default_explicit_and_empty_names;
  import uvm_pkg::*;
  initial begin
    automatic uvm_sequence_item first = new();
    automatic uvm_sequence_item named = new("named_item");
    automatic uvm_sequence_item empty_name = new("");
    $display("UT: names default %s explicit %s empty %0d", first.get_name(), named.get_name(),
             empty_name.get_name() == "");
    $display("UT: distinct %0d %0d", first != named, named != empty_name);
    $finish;
  end
endmodule
