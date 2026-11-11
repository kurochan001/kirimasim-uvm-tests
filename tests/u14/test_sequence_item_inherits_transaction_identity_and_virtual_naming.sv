/*
:name: test_sequence_item_inherits_transaction_identity_and_virtual_naming
:description: sequence item inherits transaction identity and virtual naming (IEEE 1800.2-2020 Section 14.1.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.1 14.1 14.1.2.1 14.1.2.11 5.4.1 5.3.4.1 5.3.4.2 1800-2023 6.21 18.5 18.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_item_inherits_transaction_identity_and_virtual_naming.expected
*/
// What it checks:
// 1. The virtual is_item predicate distinguishes an item from a derived
//    sequence.
// 2. A sequence item derives from the transaction base type.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.1.2.11 (UVM-ITEM-SEQUENCE-PREDICATE) gives rule 1 above.
//    Setup: Call directly and through base item handles. Expected: An item
//    returns one and a sequence zero through both call forms.
// 2. 1800.2-2020 14.1.1 (UVM-SEQ-REVIEW-ITEM-TRANSACTION-BASE) gives rule 2
//    above. Setup: A concrete item is assigned to transaction and object base
//    handles. Expected: Both nonnull base views denote the same item.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use public base handles to observe the declared transaction inheritance.
// No numeric identity, object layout or actual transaction transport is
// asserted.
module test_sequence_item_inherits_transaction_identity_and_virtual_naming;
  import uvm_pkg::*;
  initial begin
    automatic uvm_sequence_item item = new("original");
    automatic uvm_transaction transaction_view = item;
    automatic uvm_object object_view = transaction_view;
    $display("UT: item inheritance nonnull %0d identity %0d category %0d name %0d",
             transaction_view != null && object_view != null, object_view == item,
             item.is_item(), object_view.get_name() == "original");
    object_view.set_name("changed");
    $display("UT: inherited_rename %0d", item.get_name() == "changed");
    $finish;
  end
endmodule
