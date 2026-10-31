/*
:name: test_callback_object_macro_switches_between_explicit_external_contexts
:description: object callback macro uses the explicitly selected context on each invocation (IEEE 1800.2-2020 Section B.4.4)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.4 B.4.1 10.7.2.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_object_macro_switches_between_explicit_external_contexts.expected
*/
// Call one dispatcher with two external objects. Each invocation must
// select that object registration and pass the requested context argument.

module test_callback_object_macro_switches_between_explicit_external_contexts;
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
    pool_t::add(left, first);
    pool_t::add(right, second);
    caller.fire_for(left);
    $display("UT: after_left %0d %0d left_context %0d", first.calls, second.calls,
             first.seen_target == left);
    caller.fire_for(right);
    $display("UT: after_right %0d %0d right_context %0d", first.calls, second.calls,
             second.seen_target == right);
    $finish;
  end
endmodule
