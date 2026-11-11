/*
:name: test_callback_object_exit_on_empty_context_does_not_use_dispatcher_callbacks
:description: object exit-on macro invokes no callback for an empty explicit context (IEEE 1800.2-2020 Section B.4.6)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.6 B.4.1 10.7.2.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_object_exit_on_empty_context_does_not_use_dispatcher_callbacks.expected
*/
// What it checks:
// Explicit-object exit dispatch visits the selected list until a match or its
// end.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.4.6 (UVM-CALLBACK-MACRO-EXTERNAL-NO-MATCH) gives the rule
// above. Setup: Use an all-nonmatching list or an empty external context while
// the dispatcher has an entry. Expected: Nonmatching entries are all visited
// and an empty external context never invokes dispatcher entries.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Register a matching callback only on the dispatcher and select an empty
// external object. The dispatcher entry must not execute. Ignore the
// no-match function result rather than assigning an unstated default.

module test_callback_object_exit_on_empty_context_does_not_use_dispatcher_callbacks;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class user_callback extends uvm_callback;
    `uvm_object_utils(user_callback)
    int calls = 0;
    bit answer = 0;
    uvm_object seen_target;
    function new(string name="user_callback");
      super.new(name);
      void'(callback_mode(1));
    endfunction
    virtual function void hit(uvm_object selected);
      calls++;
      seen_target = selected;
    endfunction
    virtual function bit vote(uvm_object selected);
      hit(selected);
      return answer;
    endfunction
  endclass
  class agent extends uvm_component;
    `uvm_component_utils(agent)
    `uvm_register_cb(agent, user_callback)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void fire_for(agent selected);
      `uvm_do_obj_callbacks(agent, user_callback, selected, hit(selected))
    endfunction
    function bit stop_on_true_for(agent selected);
      `uvm_do_obj_callbacks_exit_on(agent, user_callback, selected, vote(selected), 1)
      return 0;
    endfunction
    function bit stop_on_false_for(agent selected);
      `uvm_do_obj_callbacks_exit_on(agent, user_callback, selected, vote(selected), 0)
      return 1;
    endfunction
  endclass
  typedef uvm_callbacks#(agent, user_callback) pool_t;

  initial begin
    automatic agent caller = new("caller", null);
    automatic agent left = new("left", null);
    automatic agent right = new("right", null);
    automatic agent empty = new("empty", null);
    automatic user_callback first = new("first");
    automatic user_callback second = new("second");
    automatic user_callback third = new("third");
    automatic user_callback outside = new("outside");
    bit result;
    outside.answer = 0;
    pool_t::add(caller, outside);
    result = caller.stop_on_false_for(empty);
    $display("UT: dispatcher_calls %0d", outside.calls);
    $finish;
  end
endmodule
