/*
:name: test_sequence_state_stopped_mask_returns_on_kill_and_again_when_already_stopped
:description: sequence state wait accepts STOPPED after kill and returns for an already matching state (IEEE 1800.2-2020 Section 14.2.2.5)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.2.5 14.2.2.4 14.2.3.1 14.2.3.6 14.2.5.11 F.2.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_state_stopped_mask_returns_on_kill_and_again_when_already_stopped.expected
*/
// What it checks:
// 1. A STOPPED-or-FINISHED wait accepts a killed sequence STOPPED state.
// 2. A state wait returns immediately when already in the selected STOPPED
//    state.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.2.5 (UVM-SEQUENCE-STATE-STOPPED-WAIT) gives rule 1
//    above. Setup: Kill during a delayed body after observing BODY. Expected:
//    State is STOPPED, waiter and start return, and body exit remains zero.
// 2. 1800.2-2020 14.2.2.5 (UVM-SEQUENCE-STATE-ALREADY-MATCHING-STOPPED) gives
//    rule 2 above. Setup: Call a STOPPED wait after the kill has settled.
//    Expected: The matching wait returns without another state transition.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Unbound virtual sequences with positive body delays; no driver or phases.
// Only mask/state behavior is asserted, not kill post-hook ordering.
module test_sequence_state_stopped_mask_returns_on_kill_and_again_when_already_stopped;
  import uvm_pkg::*;

  class delayed_sequence extends uvm_sequence#(uvm_sequence_item);
    int entries = 0;
    int exits = 0;
    function new(string name); super.new(name); endfunction
    virtual task body(); entries++; #4; exits++; endtask
  endclass
  delayed_sequence first;
  delayed_sequence peer;
  bit first_wait_returned = 0;
  bit peer_wait_returned = 0;
  bit start_returned = 0;
  initial begin
    first = new("first"); peer = new("peer");

    fork
      begin first.start(null); start_returned = 1; end
      begin
        first.wait_for_sequence_state(UVM_STOPPED | UVM_FINISHED);
        first_wait_returned = 1;
      end
      begin
        first.wait_for_sequence_state(UVM_BODY); #1; first.kill(); #1;
        $display("UT: killed stopped %0d waiter %0d start_returned %0d exits %0d",
        first.get_sequence_state() == UVM_STOPPED, first_wait_returned, start_returned,
        first.exits);
        first.wait_for_sequence_state(UVM_STOPPED);
        $display("UT: already_stopped returned 1");
      end
    join

    $finish;
  end
  initial begin #80; $fatal(1, "state wait watchdog expired"); end

endmodule
