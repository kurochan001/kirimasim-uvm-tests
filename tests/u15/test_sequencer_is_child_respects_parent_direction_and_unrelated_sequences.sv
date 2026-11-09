/*
:name: test_sequencer_is_child_respects_parent_direction_and_unrelated_sequences
:description: sequencer is_child identifies a direct child without reversing or inventing ancestry (IEEE 1800.2-2020 Section 15.3.2.2)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.2 14.1.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_is_child_respects_parent_direction_and_unrelated_sequences.expected
*/
// What it checks:
// is_child recognizes the parent-to-child direction without confusing
// unrelated sequences.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.3.2.2 (UVM-SEQUENCER-IS-CHILD-DIRECTION) gives the rule
// above. Setup: Set one direct sequence parent and compare forward, reverse
// and unrelated queries. Expected: Only the direct parent-to-child query
// returns one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Set a direct sequence parent explicitly and compare both directions
// and an unrelated sequence. Do not rely on self-ancestry behavior.

module test_sequencer_is_child_respects_parent_direction_and_unrelated_sequences;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class empty_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(empty_sequence)
    function new(string name="empty_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass
  initial begin
    automatic uvm_sequencer#(packet) sequencer = new("sequencer", null);
    automatic empty_sequence parent_value = new("parent_value");
    automatic empty_sequence child_value = new("child_value");
    automatic empty_sequence unrelated_value = new("unrelated_value");
    child_value.set_parent_sequence(parent_value);
    $display("UT: direct_child %0d reverse %0d unrelated %0d",
        sequencer.is_child(parent_value, child_value),
             sequencer.is_child(child_value, parent_value),
                 sequencer.is_child(parent_value, unrelated_value));
    $finish;
  end
endmodule
