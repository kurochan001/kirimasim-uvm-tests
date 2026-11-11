/*
:name: test_event_raw_trigger_wait_distinguishes_early_and_same_slice_late_calls
:description: event raw trigger wait distinguishes early and same slice late calls (IEEE 1800.2-2020 Section 10.1.1.2.4)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.1.2.4 10.1.1.2.10 10.1.2.2.4 10.1.2.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_raw_trigger_wait_distinguishes_early_and_same_slice_late_calls.expected
*/
// What it checks:
// 1. A raw trigger waiter established before a trigger resumes on that
//    trigger.
// 2. A raw wait called after a trigger in the same slice requires a fresh
//    trigger.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.1.1.2.4 (UVM-SYNC-REVIEW-RAW-TRIGGER-EARLY-WAITER) gives
//    rule 1 above. Setup: One process is already blocked before the first
//    accepted trigger. Expected: The early waiter has returned when observed
//    in the next time slice.
// 2. 1800.2-2020 10.1.1.2.4 (UVM-SYNC-REVIEW-RAW-TRIGGER-LATE-WAITER) gives
//    rule 2 above. Setup: The triggering process calls wait_trigger
//    immediately after trigger returns. Expected: It stays blocked with one
//    waiter until a later fresh trigger releases it.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A positive delay establishes the early raw waiter; one process then triggers
// and calls the late raw wait sequentially in the same time slice. No relative
// ordering between independently released processes or delta-cycle scheduler
// implementation is assumed.
module test_event_raw_trigger_wait_distinguishes_early_and_same_slice_late_calls;
  import uvm_pkg::*;
  uvm_event#(int) subject;
  bit early = 0,late = 0,entered = 0;
  initial begin
    subject = new("subject");
    fork
      begin entered = 1; subject.wait_trigger(); early = 1; end
      begin #2; subject.trigger(13); subject.wait_trigger(); late = 1; end
      begin
        #1;
      $display("UT: raw_trigger_established entered %0d waiters %0d",entered,
               subject.get_num_waiters());
      #2;
        $display("UT: raw_trigger early %0d late_blocked %0d waiters %0d",
                 early,!late,subject.get_num_waiters());
        #2; subject.trigger(27);
      end
    join
    $display("UT: raw_trigger_final early %0d late %0d waiters %0d data %0d",early,late,
             subject.get_num_waiters(),subject.get_trigger_data());
    $finish;
  end
  initial begin #50; $fatal(1,"raw trigger watchdog expired"); end
endmodule
