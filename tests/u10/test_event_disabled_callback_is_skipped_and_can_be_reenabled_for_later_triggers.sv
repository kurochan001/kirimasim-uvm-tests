/*
:name: test_event_disabled_callback_is_skipped_and_can_be_reenabled_for_later_triggers
:description: event dispatch honors callback enable mode across disable, enable and disable again (IEEE 1800.2-2020 Section 10.7.1.2.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.1.2.2 10.1.1.2.4 10.1.1.2.5 10.1.1.2.6 10.1.1.2.7 10.1.1.2.8 10.1.1.2.9 10.1.1.2.10 10.1.2.2.2 10.1.2.2.4 10.1.2.2.5 10.2.2.1 10.2.2.2 10.2.2.3 10.7.2.3.1 10.7.2.3.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_disabled_callback_is_skipped_and_can_be_reenabled_for_later_triggers.expected
*/
// Standard typed callbacks and explicit positive-delay waiting states.
// No compatibility add_callback wrapper or waiter release order is required.
// The pinned event dispatch does not filter disabled callbacks.
// Retain the callback-mode contract rather than its observed invocation.
module test_event_disabled_callback_is_skipped_and_can_be_reenabled_for_later_triggers;
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
  initial begin

    event_value = new("event_value"); probe = new(); probe.expected_event = event_value;
    callbacks_t::add(event_value, probe);
    void'(probe.callback_mode(0)); event_value.trigger(17);
    $display("UT: disabled pre %0d post %0d active %0d latest %0d", probe.pre_calls,
             probe.post_calls, event_value.is_on(), event_value.get_trigger_data());
    void'(probe.callback_mode(1)); event_value.reset(); event_value.trigger(42);
    $display("UT: enabled pre %0d post %0d latest %0d", probe.pre_calls, probe.post_calls,
             event_value.get_trigger_data());
    void'(probe.callback_mode(0)); event_value.trigger(73);
    $display("UT: disabled_again pre %0d post %0d latest %0d", probe.pre_calls, probe.post_calls,
             event_value.get_trigger_data());
    callbacks_t::delete(event_value, probe);

    $finish;
  end
  initial begin #60; $fatal(1, "event callback/waiter watchdog expired"); end
endmodule
