/*
:name: test_typewide_callback_applies_to_existing_and_future_objects
:description: typewide callback registration applies to existing and subsequently created objects (IEEE 1800.2-2020 Section 10.7.2.3.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.3.1 B.4.1 B.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_typewide_callback_applies_to_existing_and_future_objects.expected
*/
// Use a null registration context for a callback with a registered
// type pair. Both invocations use the same callback handle.

module test_typewide_callback_applies_to_existing_and_future_objects;
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
    automatic agent existing = new("existing", null);
    automatic user_callback typewide = new("typewide");
    agent future;
    pool_t::add(null, typewide);
    future = new("future", null);
    existing.fire();
    future.fire();
    $display("UT: shared_typewide_calls %0d", typewide.calls);
    $finish;
  end
endmodule
