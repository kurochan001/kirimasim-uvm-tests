/*
:name: test_sequencer_arbitration_modes_default_and_update_per_instance
:description: sequencer arbitration modes default to FIFO and retain independent updates (IEEE 1800.2-2020 Section 15.3.2.18)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.18 15.3.2.19 F.2.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_arbitration_modes_default_and_update_per_instance.expected
*/
// What it checks:
// The arbitration query defaults to FIFO and returns the current per-sequencer
// mode.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.3.2.18 (UVM-SEQUENCER-ARBITRATION-MODE-QUERY) gives the rule
// above. Setup: Change one instance to strict FIFO and another to random
// without issuing requests. Expected: Initial modes are FIFO and later
// settings remain independent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Inspect configured modes only. Random mode selection is not executed
// and no ordering among simultaneous requests is assumed.

module test_sequencer_arbitration_modes_default_and_update_per_instance;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_sequencer#(packet) first = new("first", null);
    automatic uvm_sequencer#(packet) second = new("second", null);
    $display("UT: default_fifo %0d %0d", first.get_arbitration() == UVM_SEQ_ARB_FIFO,
        second.get_arbitration() == UVM_SEQ_ARB_FIFO);
    first.set_arbitration(UVM_SEQ_ARB_STRICT_FIFO);
    $display("UT: first_updated %0d second_kept %0d",
        first.get_arbitration() == UVM_SEQ_ARB_STRICT_FIFO,
             second.get_arbitration() == UVM_SEQ_ARB_FIFO);
    second.set_arbitration(UVM_SEQ_ARB_RANDOM);
    $display("UT: independent_modes %0d %0d", first.get_arbitration() == UVM_SEQ_ARB_STRICT_FIFO,
             second.get_arbitration() == UVM_SEQ_ARB_RANDOM);
    $finish;
  end
endmodule
