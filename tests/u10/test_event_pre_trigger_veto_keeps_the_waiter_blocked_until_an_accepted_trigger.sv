/*
:name: test_event_pre_trigger_veto_keeps_the_waiter_blocked_until_an_accepted_trigger
:description: a pre-trigger veto prevents activation and post callbacks without losing an existing waiter (IEEE 1800.2-2020 Section 10.2.2.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.2.2.2 10.1.1.2.4 10.1.1.2.5 10.1.1.2.6 10.1.1.2.7 10.1.1.2.8 10.1.1.2.9 10.1.1.2.10 10.1.2.2.2 10.1.2.2.4 10.1.2.2.5 10.2.2.1 10.2.2.3 10.7.2.3.1 10.7.2.3.3 10.7.1.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_pre_trigger_veto_keeps_the_waiter_blocked_until_an_accepted_trigger.expected
*/
// What it checks:
// 1. A nonzero pre-trigger callback return prevents that trigger and its
//    post-trigger callbacks.
// 2. Post-trigger callbacks observe the activated event and accepted trigger
//    data.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.2.2.2 (UVM-EVENT-CALLBACK-VETO) gives rule 1 above. Setup:
//    Veto value 17 with a waiting process, then accept value 42. Expected: The
//    veto leaves the waiter blocked and event off; the accepted trigger
//    releases it with data 42.
// 2. 1800.2-2020 10.2.2.3 (UVM-EVENT-POST-CALLBACK-ACTIVATION) gives rule 2
//    above. Setup: Trigger twice around a reset with one callback and explicit
//    data. Expected: Pre/post counts and identity match; post-trigger sees
//    is_on and the supplied latest data.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Standard typed callbacks and explicit positive-delay waiting states.
// No compatibility add_callback wrapper or waiter release order is required.
module test_event_pre_trigger_veto_keeps_the_waiter_blocked_until_an_accepted_trigger;
  import uvm_pkg::*;
  typedef bit [31:0] word_t;
  typedef uvm_event#(word_t) event_t;
  typedef uvm_event_callback#(word_t) callback_t;
  typedef uvm_callbacks#(event_t, callback_t) callbacks_t;
  class watch extends callback_t;
    event_t expected_event;
    bit veto = 0;
    int pre_calls = 0;
    int post_calls = 0;
    bit identity_ok = 1;
    bit post_state_ok = 1;
    word_t last_pre = 0;
    word_t last_post = 0;
    string trace = "";
    function new(); super.new("watch"); endfunction
    virtual function bit pre_trigger(event_t e, word_t data);
      pre_calls++; last_pre = data; trace = {trace, "P"};
      identity_ok &= e == expected_event;
      return veto;
    endfunction
    virtual function void post_trigger(event_t e, word_t data);
      post_calls++; last_post = data; trace = {trace, "Q"};
      identity_ok &= e == expected_event;
      post_state_ok &= e.is_on() && e.get_trigger_data() == data;
    endfunction
  endclass
  event_t event_value;
  watch probe;
  bit returned = 0;
  word_t data;
  initial begin

    event_value = new("event_value"); probe = new(); probe.expected_event = event_value;
    callbacks_t::add(event_value, probe); probe.veto = 1;
    fork
      begin event_value.wait_trigger_data(data); returned = 1; end
      begin
        #1; event_value.trigger(17);
        #1;
        $display("UT: veto blocked %0d off %0d pre %0d post %0d time_zero %0d", !returned,
                 !event_value.is_on(), probe.pre_calls, probe.post_calls,
                 event_value.get_trigger_time() == 0);
        probe.veto = 0; event_value.trigger(42);
      end
    join
    $display("UT: accepted returned %0d data %0d pre %0d post %0d order %s", returned, data,
             probe.pre_calls, probe.post_calls, probe.trace);
    $display("UT: callback identity %0d post_state %0d last_data %0d/%0d", probe.identity_ok,
             probe.post_state_ok, probe.last_pre, probe.last_post);
    callbacks_t::delete(event_value, probe);

    $finish;
  end
  initial begin #60; $fatal(1, "event callback/waiter watchdog expired"); end
endmodule
