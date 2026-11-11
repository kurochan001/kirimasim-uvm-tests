/*
:name: test_event_on_off_waits_follow_reset_and_a_second_trigger
:description: event on and off waits retain state and reblock after reset (IEEE 1800.2-2020 Section 10.1.1.2.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.1.2.2 10.1.1.2.3 10.1.1.2.6 10.1.1.2.7 10.1.1.2.8 10.1.2.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_on_off_waits_follow_reset_and_a_second_trigger.expected
*/
// What it checks:
// 1. Event wait_on waits for activation and returns immediately while the
//    event remains on.
// 2. Event wait_off returns immediately when off and waits for reset when on.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.1.1.2.2 (UVM-EVENT-WAIT-ON-PERSISTENCE) gives rule 1
//    above. Setup: Wait before a trigger, call again while on, reset and
//    establish a fresh wait. Also exercise omitted and explicit-zero delta
//    forms over two already-satisfied and freshly blocked/released rounds,
//    with a deferred-child scheduler witness and an independent peer.
//    Expected: Each inactive wait blocks until its own trigger; the already-on
//    call returns without advancing time. An already-satisfied zero/default
//    call returns without starting its deferred child or advancing
//    time/realtime. An unsatisfied call remains blocked until the controlled
//    trigger/reset and returns with the desired state at that transition; peer
//    waits remain independent.
// 2. 1800.2-2020 10.1.1.2.3 (UVM-EVENT-WAIT-OFF-RESET) gives rule 2 above.
//    Setup: Inspect the initially off event, then wait after a trigger and
//    reset it. Also exercise omitted and explicit-zero delta forms over two
//    already-satisfied and freshly blocked/released rounds, with a
//    deferred-child scheduler witness and an independent peer. Expected: The
//    initial wait is immediate; the active wait returns only after reset and
//    the event is off. An already-satisfied zero/default call returns without
//    starting its deferred child or advancing time/realtime. An unsatisfied
//    call remains blocked until the controlled trigger/reset and returns with
//    the desired state at that transition; peer waits remain independent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive delays establish waiting states. The fixtures do not require a
// particular order among processes released at the same synchronization point.
module test_event_on_off_waits_follow_reset_and_a_second_trigger;
  import uvm_pkg::*;
  typedef bit [31:0] word_t;
  uvm_event#(word_t) event_value;
  bit on_returned = 0;
  bit off_returned = 0;
  bit second_returned = 0;
  time before_wait;
  initial begin

    event_value = new("event_value");
    before_wait = $time; event_value.wait_off();
    $display("UT: initially_off %0d immediate %0d time_zero %0d", !event_value.is_on(),
             $time == before_wait, event_value.get_trigger_time() == 0);
    fork
      begin event_value.wait_on(); on_returned = 1; end
      begin #1; $display("UT: waiting_on %0d", !on_returned); event_value.trigger(42); end
    join
    before_wait = $time; event_value.wait_on();
    $display("UT: on %0d returned %0d persistent %0d", event_value.is_on(), on_returned,
             $time == before_wait);
    fork
      begin event_value.wait_off(); off_returned = 1; end
      begin #1; $display("UT: waiting_off %0d", !off_returned); event_value.reset(); end
    join
    $display("UT: reset off %0d returned %0d time_zero %0d", !event_value.is_on(), off_returned,
             event_value.get_trigger_time() == 0);
    fork
      begin event_value.wait_on(); second_returned = 1; end
      begin #1; $display("UT: waiting_again %0d", !second_returned); event_value.trigger(73); end
    join
    $display("UT: retrigger on %0d returned %0d", event_value.is_on(), second_returned);

    $finish;
  end
  initial begin #60; $fatal(1, "synchronization watchdog expired"); end
endmodule
