/*
:name: test_callback_object_macro_includes_typewide_and_selected_instance_entries
:description: external-object dispatch includes applicable typewide and local callbacks (IEEE 1800.2-2020 Section B.4.4)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.4 B.4.1 10.7.2.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_object_macro_includes_typewide_and_selected_instance_entries.expected
*/
// What it checks:
// The explicit-object callback macro dispatches callbacks associated with its
// supplied external object.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.4.4 (UVM-CALLBACK-MACRO-EXTERNAL-CONTEXT) gives the rule
// above. Setup: Keep separate dispatcher/object registrations, include a
// typewide callback and switch between two objects. Expected:
// Selected-object/typewide entries execute with the supplied context;
// dispatcher-only entries do not.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Combine a typewide entry with one selected-object entry and an unrelated
// dispatcher entry. Count membership without assuming cross-queue ordering.

module test_callback_object_macro_includes_typewide_and_selected_instance_entries;
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
    pool_t::add(null, first);
    pool_t::add(left, second);
    pool_t::add(caller, outside);
    caller.fire_for(left);
    $display("UT: typewide %0d local %0d dispatcher %0d contexts %0d %0d", first.calls,
             second.calls, outside.calls, first.seen_target == left, second.seen_target == left);
    $finish;
  end
endmodule
