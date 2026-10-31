/*
:name: test_callback_iterator_forward_restart_resets_current_callback
:description: callback iteration honors enabled entries object context exhaustion and restart (IEEE 1800.2-2020 Section D.1.2.2)
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.1.2.2 D.1.2.3 D.1.2.4 D.1.2.5 D.1.2.6 10.7.2.3.1 10.7.1.2.2 B.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_iterator_forward_restart_resets_current_callback.expected
*/
// Exhaust the facade iterator and explicitly restart from its
// endpoint. Inspect get_cb only after a valid access, without assuming
// what an invalid or exhausted access retains.

module test_callback_iterator_forward_restart_resets_current_callback;
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
    pool_t::add(context_value, last_value);
    selected = iterator_value.first();
    $display("UT: endpoint %0d current %0d", selected == first, iterator_value.get_cb() == first);
    selected = iterator_value.next();
    $display("UT: step %0d", selected == last_value);
    selected = iterator_value.next();
    $display("UT: exhausted %0d", selected == null);
    selected = iterator_value.first();
    $display("UT: restarted %0d current %0d", selected == first, iterator_value.get_cb() == first);

    $finish;
  end
endmodule
