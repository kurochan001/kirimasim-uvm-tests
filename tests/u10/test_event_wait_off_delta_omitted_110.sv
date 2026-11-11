/*
:name: test_event_wait_off_delta_omitted_110
:description: wait_off delta omitted distinguishes deferred-child scheduling, state waiting and peer isolation (IEEE 1800.2-2020 Section 10.1.1.2.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.1.2.3 10.1.1.2.2 10.1.1.2.7 10.1.1.2.8 10.1.2.2.4 10.1.2.2.1 1800-2023 4.4.2.2 4.4.2.3 4.4.2.4 4.7 6.21 9.3.2 9.4.1 9.4.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_wait_off_delta_omitted_110.expected
:files: helpers110_event_delta/event_delta110.svh
*/
// What it checks:
// Event wait_off returns immediately when off and waits for reset when on.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.1.1.2.3 (UVM-EVENT-WAIT-OFF-RESET) gives the rule above.
// Setup: Inspect the initially off event, then wait after a trigger and reset
// it. Also exercise omitted and explicit-zero delta forms over two
// already-satisfied and freshly blocked/released rounds, with a deferred-child
// scheduler witness and an independent peer. Expected: The initial wait is
// immediate; the active wait returns only after reset and the event is off. An
// already-satisfied zero/default call returns without starting its deferred
// child or advancing time/realtime. An unsatisfied call remains blocked until
// the controlled trigger/reset and returns with the desired state at that
// transition; peer waits remain independent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Fork children start only when their parent blocks or ends. The fresh-child
// witness is separate from the unspecified order of already active waiters.
// Ready-waiter completion order is DIAG110 only. A queued NBA distinguishes
// an Inactive return from a later region. Exact delta counts and the scope
// of delta after an initially unsatisfied wait remain open.
module test_event_wait_off_delta_omitted_110;
  import uvm_pkg::*;
  localparam bit ON110=0;
  localparam int ARG110=-1;
  `include "event_delta110.svh"
  initial begin exercise110(); $finish; end
  initial begin #80; $fatal(1,"event110 scheduling watchdog expired"); end
endmodule
