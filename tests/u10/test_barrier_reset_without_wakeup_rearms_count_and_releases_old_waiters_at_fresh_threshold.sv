/*
:name: test_barrier_reset_without_wakeup_rearms_count_and_releases_old_waiters_at_fresh_threshold
:description: barrier reset without wakeup rearms count and releases old waiters only at fresh threshold (IEEE 1800.2-2020 Section 10.3.2.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.3.2.3 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_barrier_reset_without_wakeup_rearms_count_and_releases_old_waiters_at_fresh_threshold.expected
*/
// What it checks:
// 1. Barrier reset without wakeup clears the count and preserves threshold
//    without activating old callers.
// 2. When a reset barrier reaches its retained threshold again, all blocked
//    callers are released.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.3.2.3 (UVM-SYNC-REVIEW-BARRIER-SILENT-RESET-COUNT) gives
//    rule 1 above. Setup: Reset two blocked callers explicitly with wakeup
//    zero at threshold three. Expected: Count becomes zero, threshold stays
//    three and both old callers remain blocked.
// 2. 1800.2-2020 10.3.2.2 (UVM-SYNC-REVIEW-BARRIER-FRESH-RELEASE-AFTER-RESET)
//    gives rule 2 above. Setup: After silent reset, admit a fresh
//    threshold-sized group while old callers remain blocked. Expected: Two
//    fresh arrivals remain blocked; the third releases the fresh three and old
//    two, leaving count zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit reset(0) resets count without activating the two old waiters. Three
// fresh arrivals reach the retained threshold and release all waiting callers.
// No wakeup-default substitution, private queue access or exact release order
// is used. Bounded observations precede cleanup of stranded processes.
module test_barrier_reset_without_wakeup_rearms_count_and_releases_old_waiters_at_fresh_threshold;
  import uvm_pkg::*;
  uvm_barrier subject;
  process waiting[2];
  bit [4:0] completed = 0;
  initial begin
    subject = new("subject",3);
    fork
      begin waiting[0] = process::self(); subject.wait_for(); completed[0] = 1; end
      begin waiting[1] = process::self(); subject.wait_for(); completed[1] = 1; end
    join_none
    #1; subject.reset(0); #1;
    $display("UT: barrier_silent_reset waiters %0d threshold %0d old_blocked %0d",
             subject.get_num_waiters(),subject.get_threshold(),completed == 0);
    fork
      begin subject.wait_for(); completed[2] = 1; end
      begin subject.wait_for(); completed[3] = 1; end
      begin
        #1;
        $display("UT: barrier_fresh_pending waiters %0d all_blocked %0d",
                 subject.get_num_waiters(),completed == 0);
        #1; subject.wait_for(); completed[4] = 1;
      end
    join
    #1;
    $display("UT: barrier_fresh_release all %0d waiters %0d threshold %0d",completed == 31,
             subject.get_num_waiters(),subject.get_threshold());
    foreach (waiting[i]) if (!completed[i]) waiting[i].kill();
    $finish;
  end
  initial begin #50; $fatal(1,"silent barrier reset watchdog expired"); end
endmodule
