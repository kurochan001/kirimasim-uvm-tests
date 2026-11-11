/*
:name: test_callback_registration_is_scoped_to_object_instance
:description: instance callback registration affects only the selected object (IEEE 1800.2-2020 Section 10.7.2.3.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.3.1 B.4.1 B.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_registration_is_scoped_to_object_instance.expected
*/
// What it checks:
// An instance callback registration applies to its selected object context.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.7.2.3.1 (UVM-CALLBACK-INSTANCE-REGISTRATION) gives the rule
// above. Setup: Register different callbacks on two objects without any
// typewide entry. Expected: Invoking either object calls only its registered
// callback.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Invoke two context objects independently and inspect which callbacks
// ran. No typewide callback is registered.

module test_callback_registration_is_scoped_to_object_instance;
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
    automatic user_callback left_cb = new("left_cb");
    automatic user_callback right_cb = new("right_cb");
    pool_t::add(left, left_cb);
    pool_t::add(right, right_cb);
    left.fire();
    $display("UT: after_left %0d %0d", left_cb.calls, right_cb.calls);
    right.fire();
    $display("UT: after_right %0d %0d", left_cb.calls, right_cb.calls);
    $finish;
  end
endmodule
