/*
:name: test_sequence_grab_waits_for_existing_owner_to_unlock
:description: a competing lock or grab waits for the current owner before becoming the owner (IEEE 1800.2-2020 Section 14.2.5.6)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.6 14.2.5.8 14.2.5.9 14.2.5.10 14.1.2.6 15.3.2.8 15.3.2.9 15.3.2.15 15.3.2.16 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_grab_waits_for_existing_owner_to_unlock.expected
*/
// What it checks:
// A grab waits while an existing owner blocks it and returns after
// acquisition.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.2.5.6 (UVM-SEQUENCE-GRAB-WAIT-FOR-OWNER) gives the rule
// above. Setup: Hold first lock, request second grab, probe before release and
// after transfer. Expected: Second remains blocked initially, becomes exact
// owner after release, and final release clears ownership.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Hold the first lock before starting a competing acquisition. Sample
// the waiting flag after a positive delay, then release and observe the
// new owner before its own delayed release. Fork state lives in the test.

module test_sequence_grab_waits_for_existing_owner_to_unlock;
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
      first.lock();
      fork
        begin
          second.grab();

          second_granted = 1;
          #2;
          second.ungrab();

        end
        begin
          #1;
          $display("UT: waiting granted %0d first_held %0d second_blocked %0d", second_granted,
                   first.has_lock(), second.is_blocked());
          first.unlock();
          wait (second_granted);
          $display("UT: transferred second_held %0d first_blocked %0d owner_second %0d",
                   second.has_lock(), first.is_blocked(), sequencer.current_grabber() == second);
        end
      join

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
