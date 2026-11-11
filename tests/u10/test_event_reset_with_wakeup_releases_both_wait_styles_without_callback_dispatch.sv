/*
:name: test_event_reset_with_wakeup_releases_both_wait_styles_without_callback_dispatch
:description: wakeup reset releases trigger and persistent-trigger waiters without running trigger callbacks (IEEE 1800.2-2020 Section 10.1.1.2.8)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.1.2.8 10.1.1.2.4 10.1.1.2.5 10.1.1.2.6 10.1.1.2.7 10.1.1.2.9 10.1.1.2.10 10.1.2.2.2 10.1.2.2.4 10.1.2.2.5 10.2.2.1 10.2.2.2 10.2.2.3 10.7.2.3.1 10.7.2.3.3 10.7.1.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_reset_with_wakeup_releases_both_wait_styles_without_callback_dispatch.expected
*/
// What it checks:
// Wakeup reset activates existing trigger waiters, turns the event off and
// invokes no trigger callbacks.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.1.1.2.8 (UVM-EVENT-RESET-WAKEUP-CALLBACKS) gives the rule
// above. Setup: Block one wait_trigger and one wait_ptrigger, reset with
// wakeup, then wait for a later real trigger. Expected: Both old waiters
// return without callback dispatch; a fresh waiter remains blocked until
// trigger 99.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Standard typed callbacks and explicit positive-delay waiting states.
// No compatibility add_callback wrapper or waiter release order is required.
// The pinned Verilator run does not wake these established waiters.
// Preserve reset(1); the simulator/library cause remains unassigned.
module test_event_reset_with_wakeup_releases_both_wait_styles_without_callback_dispatch;
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
  bit [1:0] returned = 0;
  bit fresh = 0;
  initial begin

    event_value = new("event_value"); probe = new(); probe.expected_event = event_value;
    callbacks_t::add(event_value, probe);
    fork
      begin event_value.wait_trigger(); returned[0] = 1; end
      begin event_value.wait_ptrigger(); returned[1] = 1; end
      begin
        #1;
        $display("UT: before blocked %0d waiters %0d", returned == 0,
        event_value.get_num_waiters());
        event_value.reset(1);
      end
    join
    $display("UT: reset released %0d off %0d waiters %0d callbacks %0d/%0d", returned == 3,
             !event_value.is_on(), event_value.get_num_waiters(), probe.pre_calls,
             probe.post_calls);
    #1;
    fork
      begin event_value.wait_trigger(); fresh = 1; end
      begin #1; $display("UT: fresh_wait %0d", !fresh); event_value.trigger(99); end
    join
    $display("UT: fresh_return %0d callbacks %0d/%0d data %0d", fresh,
             probe.pre_calls, probe.post_calls, probe.last_post);
    callbacks_t::delete(event_value, probe);

    $finish;
  end
  initial begin #60; $fatal(1, "event callback/waiter watchdog expired"); end
endmodule
