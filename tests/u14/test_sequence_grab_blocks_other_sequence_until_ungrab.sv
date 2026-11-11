/*
:name: test_sequence_grab_blocks_other_sequence_until_ungrab
:description: lock and grab ownership block unrelated sequences and disappear after the public release API (IEEE 1800.2-2020 Section 14.2.5.6)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.6 14.2.5.8 14.2.5.9 14.2.5.10 14.1.2.6 15.3.2.8 15.3.2.9 15.3.2.15 15.3.2.16 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_grab_blocks_other_sequence_until_ungrab.expected
*/
// What it checks:
// A granted grab excludes unrelated sequences until its release.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.2.5.6 (UVM-SEQUENCE-GRAB-IDLE-EXCLUSION) gives the rule
// above. Setup: Request ownership on an idle bound sequencer and then release
// it. Expected: The owner holds the lock, its peer is blocked, and all
// ownership/blocking clears after release.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Bind both sequence objects to an idle sequencer. Inspect ownership
// and blocking through sequence and sequencer APIs; no item arbitration
// or running sequence body is needed to request these locks.

module test_sequence_grab_blocks_other_sequence_until_ungrab;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(empty_sequence)
    function new(string name="empty_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(uvm_sequence_item) sequencer;
    empty_sequence first;
    empty_sequence second;
    bit second_granted = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      first = new("first");
      second = new("second");
      first.set_sequencer(sequencer);
      second.set_sequencer(sequencer);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      first.grab();

      $display("UT: held %0d %0d blocked %0d %0d", first.has_lock(), second.has_lock(),
               first.is_blocked(), second.is_blocked());
      $display("UT: grabbed %0d owner_same %0d", sequencer.is_grabbed(),
               sequencer.current_grabber() == first);
      first.ungrab();

      $display("UT: cleared locks %0d %0d blocked %0d %0d grabbed %0d owner_null %0d",
               first.has_lock(), second.has_lock(), first.is_blocked(), second.is_blocked(),
               sequencer.is_grabbed(), sequencer.current_grabber() == null);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
