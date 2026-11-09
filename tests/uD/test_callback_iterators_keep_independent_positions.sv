/*
:name: test_callback_iterators_keep_independent_positions
:description: two callback iterators retain independent traversal positions for one object (IEEE 1800.2-2020 Section D.1.2.1)
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.1.2.1 D.1.2.2 D.1.2.3 D.1.2.4 D.1.2.5 D.1.2.6 10.7.2.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_iterators_keep_independent_positions.expected
*/
// What it checks:
// 1. get_cb returns the callback selected by the most recent valid iterator
//    access.
// 2. Each constructed callback iterator uses its supplied object context.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 D.1.2.6 (UVM-CALLBACK-ITERATOR-CURRENT) gives rule 1 above.
//    Setup: Inspect get_cb after successful first/last/next/prev operations,
//    including two separate iterators. Expected: Each iterator current handle
//    agrees with its own last successful access.
// 2. 1800.2-2020 D.1.2.1 (UVM-CALLBACK-ITERATOR-CONTEXT) gives rule 2 above.
//    Setup: Construct iterators on different contexts or two iterators on the
//    same context. Expected: Each selects only its context callbacks and
//    maintains its own traversal position.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Advance one iterator while observing the other current handle. No
// callback registration changes occur during iteration.

module test_callback_iterators_keep_independent_positions;
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
    automatic agent context_value = new("context_value", null);
    automatic user_callback first = new("first");
    automatic user_callback middle = new("middle");
    automatic user_callback last_value = new("last_value");
    automatic iterator_t left = new(context_value);
    automatic iterator_t right = new(context_value);
    user_callback selected;
    pool_t::add(context_value, first);
    pool_t::add(context_value, middle);
    pool_t::add(context_value, last_value);
    selected = left.first();
    $display("UT: left_first %0d", selected == first);
    selected = right.last();
    $display("UT: right_last %0d", selected == last_value);
    selected = left.next();
    $display("UT: left_middle %0d right_kept %0d", selected == middle,
        right.get_cb() == last_value);
    selected = right.prev();
    $display("UT: right_middle %0d left_kept %0d", selected == middle, left.get_cb() == middle);
    selected = left.next();
    $display("UT: left_last %0d right_kept %0d", selected == last_value, right.get_cb() == middle);
    $finish;
  end
endmodule
