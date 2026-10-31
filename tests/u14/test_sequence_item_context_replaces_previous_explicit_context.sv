/*
:name: test_sequence_item_context_replaces_previous_explicit_context
:description: item context replacement updates both supplied context handles (IEEE 1800.2-2020 Section 14.1.2.2)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.2 14.1.2.5 14.1.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_item_context_replaces_previous_explicit_context.expected
*/
// Retain the old context objects while installing a different explicit
// parent and sequencer on the same item.

module test_sequence_item_context_replaces_previous_explicit_context;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(empty_sequence)
    function new(string name="empty_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  initial begin
    automatic empty_sequence first_parent = new("first_parent");
    automatic empty_sequence second_parent = new("second_parent");
    automatic uvm_sequencer#(uvm_sequence_item) first_sequencer = new("first", null);
    automatic uvm_sequencer#(uvm_sequence_item) second_sequencer = new("second", null);
    automatic uvm_sequence_item item = new("item");
    item.set_item_context(first_parent, first_sequencer);
    item.set_item_context(second_parent, second_sequencer);
    $display("UT: parents new %0d old %0d sequencers new %0d old %0d",
             item.get_parent_sequence() == second_parent,
                 item.get_parent_sequence() == first_parent,
             item.get_sequencer() == second_sequencer, item.get_sequencer() == first_sequencer);
    $finish;
  end
endmodule
