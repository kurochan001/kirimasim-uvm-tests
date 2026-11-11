/*
:name: test_sequence_is_item_dispatch_distinguishes_sequences
:description: is_item distinguishes data items from sequences through common base handles (IEEE 1800.2-2020 Section 14.1.2.11)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.11 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_is_item_dispatch_distinguishes_sequences.expected
*/
// What it checks:
// The virtual is_item predicate distinguishes an item from a derived sequence.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.1.2.11 (UVM-ITEM-SEQUENCE-PREDICATE) gives the rule above.
// Setup: Call directly and through base item handles. Expected: An item
// returns one and a sequence zero through both call forms.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Call the virtual predicate through uvm_sequence_item handles to
// observe dynamic dispatch without implementation-specific type checks.

module test_sequence_is_item_dispatch_distinguishes_sequences;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(empty_sequence)
    function new(string name="empty_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  initial begin
    automatic uvm_sequence_item item = new("item");
    automatic empty_sequence sequence_value = new("sequence_value");
    automatic uvm_sequence_item item_base = item;
    automatic uvm_sequence_item sequence_base = sequence_value;
    $display("UT: direct item %0d sequence %0d", item.is_item(), sequence_value.is_item());
    $display("UT: base item %0d sequence %0d", item_base.is_item(), sequence_base.is_item());
    $finish;
  end
endmodule
