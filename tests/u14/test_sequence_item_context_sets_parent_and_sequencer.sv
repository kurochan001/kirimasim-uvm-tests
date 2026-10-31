/*
:name: test_sequence_item_context_sets_parent_and_sequencer
:description: item context assigns the supplied sequence and sequencer handles (IEEE 1800.2-2020 Section 14.1.2.2)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.2 14.1.2.5 14.1.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_item_context_sets_parent_and_sequencer.expected
*/
// Supply both context arguments explicitly. No expectation depends on
// implicit sequencer inheritance or generated instance identifiers.

module test_sequence_item_context_sets_parent_and_sequencer;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(empty_sequence)
    function new(string name="empty_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  initial begin
    automatic empty_sequence parent = new("parent");
    automatic uvm_sequencer#(uvm_sequence_item) sequencer = new("sequencer", null);
    automatic uvm_sequence_item item = new("item");
    item.set_item_context(parent, sequencer);
    $display("UT: parent_same %0d sequencer_same %0d", item.get_parent_sequence() == parent,
             item.get_sequencer() == sequencer);
    $finish;
  end
endmodule
