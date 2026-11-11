/*
:name: test_sequence_info_flags_default_off_and_are_per_instance
:description: sequence information flags default to zero and remain independent between instances (IEEE 1800.2-2020 Section 14.1.2.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_info_flags_default_off_and_are_per_instance.expected
*/
// What it checks:
// The sequence-info control defaults to zero and retains per-instance updates.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.1.2.3 (UVM-ITEM-SEQUENCE-INFO-CONTROL) gives the rule above.
// Setup: Inspect a new item and sequence before using context setters.
// Expected: Both defaults are zero and independent set/clear operations remain
// local.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Change flags directly without executing an item context setter,
// which can also initialize sequence metadata.

module test_sequence_info_flags_default_off_and_are_per_instance;
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
    $display("UT: defaults %0d %0d", item.get_use_sequence_info(),
        sequence_value.get_use_sequence_info());
    item.set_use_sequence_info(1);
    $display("UT: item_enabled %0d %0d", item.get_use_sequence_info(),
        sequence_value.get_use_sequence_info());
    sequence_value.set_use_sequence_info(1);
    item.set_use_sequence_info(0);
    $display("UT: independently_updated %0d %0d", item.get_use_sequence_info(),
        sequence_value.get_use_sequence_info());
    $finish;
  end
endmodule
