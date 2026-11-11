/*
:name: test_callback_static_iterators_keep_object_contexts_separate
:description: callback iteration honors enabled entries object context exhaustion and restart (IEEE 1800.2-2020 Section 10.7.2.4.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.4.1 10.7.2.4.3 10.7.2.3.1 10.7.1.2.2 B.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_static_iterators_keep_object_contexts_separate.expected
*/
// What it checks:
// get_next advances its iterator through enabled callbacks and remains null
// after exhaustion until reset.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.7.2.4.3 (UVM-CALLBACK-STATIC-NEXT) gives the rule above.
// Setup: Traverse in the selected direction with disabled entries, independent
// iterators and typewide-only queries. Expected: Valid entries follow the
// selected queue; exhausted calls stay null and separate positions remain
// independent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use separate integer iterators for different object queues, each with
// one callback. Exhaust and restart without moving or leaking entries
// between object contexts.

module test_callback_static_iterators_keep_object_contexts_separate;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class user_callback extends uvm_callback;
    `uvm_object_utils(user_callback)
    function new(string name="user_callback");
      super.new(name);
      void'(callback_mode(1));
    endfunction
  endclass
  class agent extends uvm_component;
    `uvm_component_utils(agent)
    `uvm_register_cb(agent, user_callback)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  typedef uvm_callbacks#(agent, user_callback) pool_t;
  typedef uvm_callback_iter#(agent, user_callback) iterator_t;

  initial begin
    automatic agent context_value = new("context_value", null);
    automatic agent other_context = new("other_context", null);
    automatic user_callback first = new("first");
    automatic user_callback middle = new("middle");
    automatic user_callback last_value = new("last_value");
    automatic iterator_t iterator_value = new(context_value);
    int position;
    int other_position;
    user_callback selected;
    user_callback other_selected;
    position = 0;
    other_position = 0;
    pool_t::add(context_value, first);
    pool_t::add(other_context, last_value);
    selected = pool_t::get_first(position, context_value);
    other_selected = pool_t::get_first(other_position, other_context);
    $display("UT: own_entries %0d %0d", selected == first, other_selected == last_value);
    selected = pool_t::get_next(position, context_value);
    other_selected = pool_t::get_next(other_position, other_context);
    $display("UT: exhausted %0d %0d", selected == null, other_selected == null);
    selected = pool_t::get_first(position, context_value);
    other_selected = pool_t::get_first(other_position, other_context);
    $display("UT: restarted %0d %0d", selected == first, other_selected == last_value);

    $finish;
  end
endmodule
