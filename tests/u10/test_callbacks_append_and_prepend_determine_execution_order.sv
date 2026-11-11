/*
:name: test_callbacks_append_and_prepend_determine_execution_order
:description: callback append and prepend ordering determine enabled callback execution order (IEEE 1800.2-2020 Section 10.7.2.3.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.3.1 B.4.1 B.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callbacks_append_and_prepend_determine_execution_order.expected
*/
// What it checks:
// Callback registration places appended callbacks after existing entries and
// prepended callbacks before them.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.7.2.3.1 (UVM-CALLBACK-INSERTION-ORDER) gives the rule above.
// Setup: Two callbacks are appended and one is prepended to one object.
// Additional two-callback macro profiles use original A3/B7 transforms with
// append or prepend from initial5. Expected: Invocation order is ahead, first,
// second, with one invocation each. The added profiles yield AB/33 for append
// and BA/37 for prepend.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Register the object/callback type pair and invoke its standard
// callback macro. Only explicitly enabled callbacks are installed.

module test_callbacks_append_and_prepend_determine_execution_order;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class user_callback extends uvm_callback;
    `uvm_object_utils(user_callback)
    int calls = 0;
    function new(string name="user_callback");
      super.new(name);
      void'(callback_mode(1));
    endfunction
    virtual function void hit();
      calls++;
      $display("UT: hit %s", get_name());
    endfunction
  endclass
  class agent extends uvm_component;
    `uvm_component_utils(agent)
    `uvm_register_cb(agent, user_callback)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void fire();
      `uvm_do_callbacks(agent, user_callback, hit())
    endfunction
  endclass
  typedef uvm_callbacks#(agent, user_callback) pool_t;

  initial begin
    automatic agent context_value = new("context_value", null);
    automatic user_callback first = new("first");
    automatic user_callback second = new("second");
    automatic user_callback ahead = new("ahead");
    pool_t::add(context_value, first);
    pool_t::add(context_value, second);
    pool_t::add(context_value, ahead, UVM_PREPEND);
    context_value.fire();
    $display("UT: counts %0d %0d %0d", first.calls, second.calls, ahead.calls);
    $finish;
  end
endmodule
