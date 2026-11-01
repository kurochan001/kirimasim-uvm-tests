/*
:name: test_event_cancel_removes_a_killed_waiter_without_releasing_the_survivor
:description: cancel updates event waiter count after process termination and preserves another pending waiter (IEEE 1800.2-2020 Section 10.1.1.2.9)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.1.2.9 10.1.1.2.4 10.1.1.2.10 10.1.2.2.4 1800-2023 9.7 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_cancel_removes_a_killed_waiter_without_releasing_the_survivor.expected
*/
// Establish waiters with positive delays, then kill one and explicitly
// remove its count. Surviving processes retain their waiting state.
module test_event_cancel_removes_a_killed_waiter_without_releasing_the_survivor;
  import uvm_pkg::*;
  typedef bit [31:0] word_t;
  typedef uvm_event#(word_t) event_t;
  event_t event_value;
  process victim;
  bit canceled_returned = 0;
  bit survivor_returned = 0;
  initial begin

    event_value = new("event_value");
    fork
      begin victim = process::self(); event_value.wait_trigger(); canceled_returned = 1; end
      begin event_value.wait_trigger(); survivor_returned = 1; end
      begin
        #1;
        $display("UT: initial blocked %0d waiters %0d", !canceled_returned && !survivor_returned,
                 event_value.get_num_waiters());
        if (victim == null) $fatal(1, "waiter process missing");
        victim.kill(); event_value.cancel();
        #1;
        $display("UT: canceled waiters %0d survivor_waiting %0d victim_stopped %0d",
                 event_value.get_num_waiters(), !survivor_returned,
                 victim.status() == process::KILLED);
        event_value.trigger(42);
      end
    join
    $display("UT: completion survivor %0d victim_returned %0d waiters %0d", survivor_returned,
             canceled_returned, event_value.get_num_waiters());

    $finish;
  end
  initial begin #60; $fatal(1, "event callback/waiter watchdog expired"); end
endmodule
