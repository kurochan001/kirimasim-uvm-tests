/*
:name: test_typewide_callback_delete_preserves_instance_callback
:description: typewide callback deletion removes global registration and keeps instance callbacks (IEEE 1800.2-2020 Section 10.7.2.3.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.3.3 10.7.2.3.1 B.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_typewide_callback_delete_preserves_instance_callback.expected
*/
// Delete through the null context, then invoke two objects. The
// instance-only callback on the left must remain active.

module test_typewide_callback_delete_preserves_instance_callback;
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
    automatic user_callback local_value = new("local_value");
    pool_t::add(null, typewide);
    pool_t::add(left, local_value);
    pool_t::delete(null, typewide);
    left.fire();
    right.fire();
    $display("UT: counts typewide %0d local %0d", typewide.calls, local_value.calls);
    $finish;
  end
endmodule
