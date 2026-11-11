/*
:name: test_sequence_item_sequencer_reference_can_change_while_inactive
:description: inactive item sequencer references update immediately and can be cleared (IEEE 1800.2-2020 Section 14.1.2.6)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.6 14.1.2.5 14.1.2.7 14.1.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_item_sequencer_reference_can_change_while_inactive.expected
*/
// What it checks:
// Setting an inactive item sequencer takes effect immediately and does not
// replace its parent.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.1.2.6 (UVM-ITEM-INACTIVE-SEQUENCER-REFERENCE) gives the rule
// above. Setup: Set two sequencer handles and null without active item
// communication. Expected: Each query sees the current handle/null and retains
// the parent handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Do not change a sequencer during active communication. Parent
// sequence identity is retained across independent sequencer updates.

module test_sequence_item_sequencer_reference_can_change_while_inactive;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(empty_sequence)
    function new(string name="empty_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  initial begin
    automatic empty_sequence parent = new("parent");
    automatic uvm_sequence_item item = new("item");
    automatic uvm_sequencer#(uvm_sequence_item) first = new("first", null);
    automatic uvm_sequencer#(uvm_sequence_item) second = new("second", null);
    item.set_parent_sequence(parent);
    item.set_sequencer(first);
    $display("UT: first_same %0d", item.get_sequencer() == first);
    item.set_sequencer(second);
    $display("UT: second_same %0d parent_kept %0d", item.get_sequencer() == second,
        item.get_parent_sequence() == parent);
    item.set_sequencer(null);
    $display("UT: cleared %0d parent_kept %0d", item.get_sequencer() == null,
        item.get_parent_sequence() == parent);
    $finish;
  end
endmodule
