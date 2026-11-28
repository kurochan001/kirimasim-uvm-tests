/*
:name: test_barrier_silent_reset_rearms_count_and_releases_a_fresh_group
:description: barrier reset without wakeup clears the count and rearms the retained threshold (IEEE 1800.2-2020 Section 10.3.2.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.3.2.3 10.3.2.1 10.3.2.2 10.3.2.4 10.3.2.5 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_barrier_silent_reset_rearms_count_and_releases_a_fresh_group.expected
*/
// What it checks:
// 1. Reset with wakeup disabled clears the waiter count, retains the threshold,
//    and leaves the existing callers blocked at the reset checkpoint.
// 2. A fresh group waits for the retained threshold, then completes.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.3.2.3 (UVM-SYNC-REVIEW-BARRIER-SILENT-RESET-COUNT)
//    resets the count without changing the threshold. The wakeup argument is
//    zero, so the two pending calls do not resume at the reset checkpoint.
// 2. 1800.2-2020 10.3.2.2 (UVM-SYNC-REVIEW-BARRIER-FRESH-RELEASE-AFTER-RESET)
//    blocks the first two fresh callers until the third reaches the threshold.
//    The default automatic reset clears the count again (10.3.2.4).
// Observe the pre-reset callers through the reset checkpoint. Clean up any
// blocked callers after the new group completes and its result is recorded.
module test_barrier_silent_reset_rearms_count_and_releases_a_fresh_group;
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
    #1;
    $display("UT: barrier_before_silent_reset waiters %0d threshold %0d old_blocked %0d",
             subject.get_num_waiters(), subject.get_threshold(), completed[1:0] == 0);
    subject.reset(0);
    #1;
    $display("UT: barrier_silent_reset waiters %0d threshold %0d old_blocked %0d",
             subject.get_num_waiters(), subject.get_threshold(), completed[1:0] == 0);
    fork
      begin subject.wait_for(); completed[2] = 1; end
      begin subject.wait_for(); completed[3] = 1; end
      begin
        #1;
        $display("UT: barrier_fresh_pending waiters %0d fresh_blocked %0d",
                 subject.get_num_waiters(), completed[4:2] == 0);
        #1; subject.wait_for(); completed[4] = 1;
      end
    join
    #1;
    $display("UT: barrier_fresh_release fresh_done %0d waiters %0d threshold %0d",
             completed[4:2] == 7, subject.get_num_waiters(), subject.get_threshold());
    foreach (waiting[i]) if (!completed[i]) waiting[i].kill();
    $finish;
  end
  initial begin #50; $fatal(1,"silent barrier reset watchdog expired"); end
endmodule
