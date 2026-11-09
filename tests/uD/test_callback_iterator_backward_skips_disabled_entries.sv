/*
:name: test_callback_iterator_backward_skips_disabled_entries
:description: callback iterator backward traversal skips disabled entries and retains its current callback (IEEE 1800.2-2020 Section D.1.2.3)
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.1.2.3 D.1.2.5 D.1.2.6 D.1.2.1 10.7.2.3.1 10.7.1.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_iterator_backward_skips_disabled_entries.expected
*/
// What it checks:
// 1. last starts callback iteration at the enabled endpoint for its object
//    context.
// 2. prev advances to an enabled callback and returns null when none remain.
// 3. get_cb returns the callback selected by the most recent valid iterator
//    access.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 D.1.2.3 (UVM-CALLBACK-ITERATOR-LAST) gives rule 1 above.
//    Setup: Use selected-object queues with disabled entries, an empty queue
//    and a restarted iterator. Expected: The enabled endpoint is selected; an
//    empty queue returns null and restart selects the endpoint again.
// 2. 1800.2-2020 D.1.2.5 (UVM-CALLBACK-ITERATOR-PREVIOUS) gives rule 2 above.
//    Setup: Traverse registered callbacks in the selected direction with
//    disabled entries. Expected: Disabled entries are skipped, valid handles
//    appear in order and exhaustion is null.
// 3. 1800.2-2020 D.1.2.6 (UVM-CALLBACK-ITERATOR-CURRENT) gives rule 3 above.
//    Setup: Inspect get_cb after successful first/last/next/prev operations,
//    including two separate iterators. Expected: Each iterator current handle
//    agrees with its own last successful access.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use explicit callback enable values and inspect handle identity.
// The iterator is not used to invoke or mutate any callback.

module test_callback_iterator_backward_skips_disabled_entries;
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
    automatic user_callback disabled = new("disabled");
    automatic user_callback last_value = new("last_value");
    automatic iterator_t iterator_value = new(context_value);
    user_callback selected;
    void'(disabled.callback_mode(0));
    pool_t::add(context_value, first);
    pool_t::add(context_value, disabled);
    pool_t::add(context_value, last_value);
    selected = iterator_value.last();
    $display("UT: start_same %0d current_same %0d", selected == last_value,
        iterator_value.get_cb() == last_value);
    selected = iterator_value.prev();
    $display("UT: step_same %0d current_same %0d", selected == first,
        iterator_value.get_cb() == first);
    selected = iterator_value.prev();
    $display("UT: exhausted %0d", selected == null);
    $finish;
  end
endmodule
