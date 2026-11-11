/*
:name: test_event_cancel_reuse_trigger_111
:description: event cancel/count reuse with trigger waiters (IEEE 1800.2-2020 Section 10.1.1.2.9)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.1.2.9 10.1.1.2.10 10.1.1.2.2 10.1.1.2.3 10.1.1.2.4 10.1.1.2.5 10.1.1.2.8 10.1.2.2.1 10.1.2.2.4 1800-2023 6.21 9.3.2 9.7
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_cancel_reuse_trigger_111.expected
:files: helpers111_cancel/event_cancel111.svh
*/
// What it checks:
// 1. Event cancel decrements the count after a waiting process is killed.
// 2. The event waiter query reports the processes actually blocked on that
//    event.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.1.1.2.9 (UVM-EVENT-CANCEL-KILLED-WAITER) gives rule 1
//    above. Setup: Kill one of two waiters, cancel it, then trigger the
//    surviving waiter. In additional independent profiles, establish three
//    actual wait_trigger, wait_ptrigger, wait_on or wait_off callers on one
//    event, kill/cancel two selected callers sequentially and release the
//    survivor using the appropriate trigger/reset. Repeat on the same event
//    with an independently held peer. Expected: The count falls from two to
//    one without releasing the survivor, then reaches zero after its trigger.
//    The added three-caller histories report 3 before cancellation, 2 after
//    the first kill/cancel, 1 after the second and 0 after the survivor
//    returns. Both terminated callers remain unreturned, the survivor stays
//    blocked until its release, and the peer remains one until independently
//    released to zero, in both reuse rounds.
// 2. 1800.2-2020 10.1.1.2.10 (UVM-SYNC-REVIEW-EVENT-ACTUAL-WAITER-COUNT) gives
//    rule 2 above. Setup: Reset the selected off event without wakeup while
//    its mixed waiters remain blocked. In additional independent profiles,
//    establish three actual wait_trigger, wait_ptrigger, wait_on or wait_off
//    callers on one event, kill/cancel two selected callers sequentially and
//    release the survivor using the appropriate trigger/reset. Repeat on the
//    same event with an independently held peer. Expected: Three selected wait
//    styles and one peer off-wait produce counts three/one; no-wakeup reset
//    preserves the three blocked callers. The added three-caller histories
//    report 3 before cancellation, 2 after the first kill/cancel, 1 after the
//    second and 0 after the survivor returns. Both terminated callers remain
//    unreturned, the survivor stays blocked until its release, and the peer
//    remains one until independently released to zero, in both reuse rounds.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Two explicit kill/cancel pairs leave one real waiter blocked until its
// controlled release. Reuse the same event; keep a separate peer pending.
// No live-process cancellation, between-pair count or winner order is fixed.
module test_event_cancel_reuse_trigger_111;
  import uvm_pkg::*;
  localparam int STYLE111=0;
  `include "event_cancel111.svh"
  initial begin exercise111(); $finish; end
  initial begin #80; $fatal(1,"event111 cancellation watchdog expired"); end
endmodule
