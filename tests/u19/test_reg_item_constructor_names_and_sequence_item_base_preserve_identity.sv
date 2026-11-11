/*
:name: test_reg_item_constructor_names_and_sequence_item_base_preserve_identity
:description: reg item constructor names and sequence item base preserve identity (IEEE 1800.2-2020 Section 19.1.1.3.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.3.1 19.1.1.1 14.1.1 5.3.4.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_constructor_names_and_sequence_item_base_preserve_identity.expected
*/
// What it checks:
// 1. A register item derives from the sequence-item base.
// 2. The register-item constructor accepts an optional name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.1.1.1 (UVM-REG-INTERACTION-ITEM-BASE) gives rule 1 above.
//    Setup: Assign a named register item to a sequence-item handle. Expected:
//    The nonnull base view denotes the same object.
// 2. 1800.2-2020 19.1.1.3.1 (UVM-REG-INTERACTION-ITEM-NAMES) gives rule 2
//    above. Setup: Construct omitted-name, selected-name and explicitly
//    empty-name objects. Expected: Names are respectively empty, selected and
//    empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe public construction and base identity only. No default undefined
// kind/data/enum value, numeric identity or formatted diagnostic is asserted.
module test_reg_item_constructor_names_and_sequence_item_base_preserve_identity;
  import uvm_pkg::*;
  initial begin
    automatic uvm_reg_item omitted = new();
    automatic uvm_reg_item named = new("selected");
    automatic uvm_reg_item empty = new("");
    automatic uvm_sequence_item item_view = named;
    $display("UT: item_names omitted %0d named %0d empty %0d",
             omitted.get_name() == "", named.get_name() == "selected", empty.get_name() == "");
    $display("UT: item_base nonnull %0d identity %0d", item_view != null, item_view == named);
    $finish;
  end
endmodule
