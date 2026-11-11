/*
:name: test_barrier_raised_threshold_keeps_waiters_and_peer_progress_independent
:description: barrier raised threshold keeps waiters and peer progress independent (IEEE 1800.2-2020 Section 10.3.2.7)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.3.2.7 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_barrier_raised_threshold_keeps_waiters_and_peer_progress_independent.expected
*/
// What it checks:
// 1. Barrier waiter counts report current blocked callers independently per
//    barrier.
// 2. Raising a pending barrier threshold keeps existing callers blocked until
//    the new threshold is reached.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.3.2.7 (UVM-SYNC-REVIEW-BARRIER-ACTUAL-WAITER-COUNT) gives
//    rule 1 above. Setup: Hold two callers on one barrier and one on another,
//    then add selected arrivals. Expected: Counts progress through two/one,
//    three/one and zero/zero without releasing the other barrier early.
// 2. 1800.2-2020 10.3.2.6 (UVM-SYNC-REVIEW-BARRIER-RAISED-THRESHOLD) gives
//    rule 2 above. Setup: Raise three to four while only two callers are
//    waiting, then admit a third and fourth. Expected: Three remain blocked;
//    all four release only at the fourth arrival while a peer completes
//    independently.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Raise a pending threshold before the old threshold is reached; a distinct
// barrier completes while this one remains blocked. Observe public counts only
// after positive settling delays, without fixing released-process order or
// assuming zero/negative-threshold semantics.
module test_barrier_raised_threshold_keeps_waiters_and_peer_progress_independent;
  import uvm_pkg::*;
  uvm_barrier subject,peer;
  bit [3:0] completed = 0;
  bit [1:0] peer_completed = 0;
  initial begin
    subject = new("subject",3); peer = new("peer",2);
    fork
      begin subject.wait_for(); completed[0] = 1; end
      begin subject.wait_for(); completed[1] = 1; end
      begin peer.wait_for(); peer_completed[0] = 1; end
      begin
        #1;
        $display("UT: barrier_pending subject %0d peer %0d blocked %0d",
                 subject.get_num_waiters(),peer.get_num_waiters(),completed == 0);
        subject.set_threshold(4);
        fork
          begin subject.wait_for(); completed[2] = 1; end
          begin
            #1;
            $display("UT: barrier_raised threshold %0d waiters %0d blocked %0d",
                     subject.get_threshold(),subject.get_num_waiters(),completed == 0);
            peer.wait_for(); peer_completed[1] = 1; #1;
            $display("UT: barrier_peer complete %0d subject_blocked %0d subject_waiters %0d",
                     peer_completed == 3,completed == 0,subject.get_num_waiters());
            subject.wait_for(); completed[3] = 1;
          end
        join
      end
    join
    $display("UT: barrier_final subject %0d peer %0d waiters %0d/%0d",completed == 15,
             peer_completed == 3,subject.get_num_waiters(),peer.get_num_waiters());
    $finish;
  end
  initial begin #50; $fatal(1,"raised barrier watchdog expired"); end
endmodule
