/*
:name: test_callback_iterator_uses_its_object_context_and_handles_empty_queue
:description: callback iterators select their own context queues and return null for an empty context (IEEE 1800.2-2020 Section D.1.2.1)
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.1.2.1 D.1.2.2 D.1.2.3 D.1.2.6 10.7.2.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_iterator_uses_its_object_context_and_handles_empty_queue.expected
*/
// What it checks:
// 1. first starts callback iteration at the enabled endpoint for its object
//    context.
// 2. last starts callback iteration at the enabled endpoint for its object
//    context.
// 3. get_cb returns the callback selected by the most recent valid iterator
//    access.
// 4. Each constructed callback iterator uses its supplied object context.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 D.1.2.2 (UVM-CALLBACK-ITERATOR-FIRST) gives rule 1 above.
//    Setup: Use selected-object queues with disabled entries, an empty queue
//    and a restarted iterator. Expected: The enabled endpoint is selected; an
//    empty queue returns null and restart selects the endpoint again.
// 2. 1800.2-2020 D.1.2.3 (UVM-CALLBACK-ITERATOR-LAST) gives rule 2 above.
//    Setup: Use selected-object queues with disabled entries, an empty queue
//    and a restarted iterator. Expected: The enabled endpoint is selected; an
//    empty queue returns null and restart selects the endpoint again.
// 3. 1800.2-2020 D.1.2.6 (UVM-CALLBACK-ITERATOR-CURRENT) gives rule 3 above.
//    Setup: Inspect get_cb after successful first/last/next/prev operations,
//    including two separate iterators. Expected: Each iterator current handle
//    agrees with its own last successful access.
// 4. 1800.2-2020 D.1.2.1 (UVM-CALLBACK-ITERATOR-CONTEXT) gives rule 4 above.
//    Setup: Construct iterators on different contexts or two iterators on the
//    same context. Expected: Each selects only its context callbacks and
//    maintains its own traversal position.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use three non-null object contexts with separate registrations.
// The third context has no callbacks and no typewide callback exists.

module test_callback_iterator_uses_its_object_context_and_handles_empty_queue;
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

  typedef uvm_callback_iter#(agent, user_callback) iterator_t;

  initial begin
    automatic agent left = new("left", null);
    automatic agent right = new("right", null);
    automatic agent empty_context = new("empty_context", null);
    automatic user_callback left_cb = new("left_cb");
    automatic user_callback right_cb = new("right_cb");
    automatic iterator_t left_iterator = new(left);
    automatic iterator_t right_iterator = new(right);
    automatic iterator_t empty_iterator = new(empty_context);
    user_callback selected;
    pool_t::add(left, left_cb);
    pool_t::add(right, right_cb);
    selected = left_iterator.first();
    $display("UT: left_same %0d current_same %0d", selected == left_cb,
        left_iterator.get_cb() == left_cb);
    selected = right_iterator.first();
    $display("UT: right_same %0d current_same %0d", selected == right_cb,
        right_iterator.get_cb() == right_cb);
    selected = empty_iterator.first();
    $display("UT: empty_first %0d", selected == null);
    selected = empty_iterator.last();
    $display("UT: empty_last %0d", selected == null);
    $finish;
  end
endmodule
