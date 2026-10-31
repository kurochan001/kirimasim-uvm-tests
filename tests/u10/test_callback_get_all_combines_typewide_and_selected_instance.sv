/*
:name: test_callback_get_all_combines_typewide_and_selected_instance
:description: get_all combines typewide and selected instance callbacks while excluding another instance (IEEE 1800.2-2020 Section 10.7.2.5)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.5 10.7.2.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_get_all_combines_typewide_and_selected_instance.expected
*/
// Use distinct callback handles for global and per-instance entries.
// The null query selects only the typewide callback queue.

module test_callback_get_all_combines_typewide_and_selected_instance;
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
    automatic agent left = new("left", null);
    automatic agent right = new("right", null);
    automatic user_callback typewide = new("typewide");
    automatic user_callback left_cb = new("left_cb");
    automatic user_callback right_cb = new("right_cb");
    user_callback selected[$];
    user_callback global_values[$];
    int type_count;
    int left_count;
    int right_count;
    pool_t::add(null, typewide);
    pool_t::add(left, left_cb);
    pool_t::add(right, right_cb);
    pool_t::get_all(selected, left);
    pool_t::get_all(global_values, null);
    type_count = 0;
    left_count = 0;
    right_count = 0;
    foreach (selected[i]) begin
      if (selected[i] == typewide) type_count++;
      if (selected[i] == left_cb) left_count++;
      if (selected[i] == right_cb) right_count++;
    end
    $display("UT: selected size %0d typewide %0d left %0d right %0d", selected.size(),
        type_count, left_count, right_count);
    if (global_values.size() != 1) $fatal(1, "typewide queue size differs");
    $display("UT: global size %0d typewide_same %0d", global_values.size(),
        global_values[0] == typewide);
    $finish;
  end
endmodule
