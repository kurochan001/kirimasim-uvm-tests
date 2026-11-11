/*
:name: test_barrier_cancel_removes_a_killed_participant_before_a_fresh_threshold_group
:description: barrier cancel removes a killed participant without counting it toward the next threshold (IEEE 1800.2-2020 Section 10.3.2.8)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.3.2.8 10.3.2.1 10.3.2.2 10.3.2.4 10.3.2.7 1800-2023 9.7 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_barrier_cancel_removes_a_killed_participant_before_a_fresh_threshold_group.expected
*/
// What it checks:
// Barrier cancel removes a waiting participant from threshold accounting.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.3.2.8 (UVM-BARRIER-CANCEL-KILLED-PARTICIPANT) gives the rule
// above. Setup: Use threshold three, kill/cancel one of two waiters, then add
// two fresh live callers. Expected: Counts change two/one/two and only three
// live participants complete the threshold group.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Establish waiters with positive delays, then kill one and explicitly
// remove its count. Surviving processes retain their waiting state.
module test_barrier_cancel_removes_a_killed_participant_before_a_fresh_threshold_group;
  import uvm_pkg::*;
  uvm_barrier barrier_value;
  process victim;
  bit canceled_returned = 0;
  bit [2:0] completed = 0;
  initial begin

    barrier_value = new("barrier_value", 3);
    fork
      begin victim = process::self(); barrier_value.wait_for(); canceled_returned = 1; end
      begin barrier_value.wait_for(); completed[0] = 1; end
      begin
        #1;
        $display("UT: initial waiters %0d blocked %0d", barrier_value.get_num_waiters(),
                 completed == 0 && !canceled_returned);
        if (victim == null) $fatal(1, "barrier process missing");
        victim.kill(); barrier_value.cancel();
        $display("UT: canceled waiters %0d", barrier_value.get_num_waiters());
        fork
          begin barrier_value.wait_for(); completed[1] = 1; end
          begin
            #1;
            $display("UT: still_below waiters %0d blocked %0d", barrier_value.get_num_waiters(),
                     completed == 0);
            barrier_value.wait_for(); completed[2] = 1;
          end
        join
      end
    join
    $display("UT: complete all %0d victim_returned %0d waiters %0d", completed == 7,
             canceled_returned, barrier_value.get_num_waiters());

    $finish;
  end
  initial begin #60; $fatal(1, "event callback/waiter watchdog expired"); end
endmodule
