/*
:name: test_callback_delete_is_local_when_a_handle_is_shared
:description: deleting a shared callback from one object leaves its other registration active (IEEE 1800.2-2020 Section 10.7.2.3.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.3.3 10.7.2.3.1 B.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_delete_is_local_when_a_handle_is_shared.expected
*/
// Register one callback handle on two contexts, delete one registration
// and invoke both contexts. The callback itself remains enabled.

module test_callback_delete_is_local_when_a_handle_is_shared;
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
    automatic user_callback shared = new("shared");
    pool_t::add(left, shared);
    pool_t::add(right, shared);
    pool_t::delete(left, shared);
    left.fire();
    $display("UT: after_left calls %0d enabled %0d", shared.calls, shared.is_enabled());
    right.fire();
    $display("UT: after_right calls %0d enabled %0d", shared.calls, shared.is_enabled());
    $finish;
  end
endmodule
