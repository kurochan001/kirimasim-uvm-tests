/*
:name: test_callback_exit_on_true_stops_before_later_callbacks
:description: callback exit-on macro stops after the first callback returning true (IEEE 1800.2-2020 Section B.4.5)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.5 B.4.1 10.7.2.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_exit_on_true_stops_before_later_callbacks.expected
*/
// What it checks:
// The callback exit macro returns when the first callback produces the
// selected bit value.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.4.5 (UVM-CALLBACK-MACRO-EXIT-ON) gives the rule above. Setup:
// Test both exit-on-zero and exit-on-one with a later callback registered.
// Expected: The matching callback runs once, later callbacks do not run and
// the enclosing function returns that value.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use callbacks with explicit boolean results. The enclosing
// function returns the selected value and later callbacks must not execute.

module test_callback_exit_on_true_stops_before_later_callbacks;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class user_callback extends uvm_callback;
    `uvm_object_utils(user_callback)
    int calls = 0;
    bit answer = 0;
    function new(string name="user_callback");
      super.new(name);
      void'(callback_mode(1));
    endfunction
    virtual function void hit();
      calls++;
      $display("UT: hit %s", get_name());
    endfunction
    virtual function bit vote();
      calls++;
      $display("UT: vote %s", get_name());
      return answer;
    endfunction
  endclass
  class agent extends uvm_component;
    `uvm_component_utils(agent)
    `uvm_register_cb(agent, user_callback)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void fire();
      `uvm_do_callbacks(agent, user_callback, hit())
    endfunction
    function bit stop_on_true();
      `uvm_do_callbacks_exit_on(agent, user_callback, vote(), 1)
      return 0;
    endfunction
    function bit stop_on_false();
      `uvm_do_callbacks_exit_on(agent, user_callback, vote(), 0)
      return 1;
    endfunction
  endclass
  typedef uvm_callbacks#(agent, user_callback) pool_t;

  initial begin
    automatic agent context_value = new("context_value", null);
    automatic user_callback first = new("first");
    automatic user_callback stop_value = new("stop_value");
    automatic user_callback later = new("later");
    bit result;
    first.answer = 0;
    stop_value.answer = 1;
    later.answer = 0;
    pool_t::add(context_value, first);
    pool_t::add(context_value, stop_value);
    pool_t::add(context_value, later);
    result = context_value.stop_on_true();
    $display("UT: result %0d calls %0d %0d %0d", result, first.calls, stop_value.calls,
        later.calls);
    $finish;
  end
endmodule
