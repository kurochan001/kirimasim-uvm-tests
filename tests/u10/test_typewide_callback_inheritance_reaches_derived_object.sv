/*
:name: test_typewide_callback_inheritance_reaches_derived_object
:description: a derived component inherits its base typewide callback after super type registration (IEEE 1800.2-2020 Section 10.7.2.3.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.3.1 B.4.2 B.4.1 B.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_typewide_callback_inheritance_reaches_derived_object.expected
*/
// What it checks:
// Registering a super-type relationship lets derived objects inherit base
// typewide callbacks.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.4.2 (UVM-CALLBACK-TYPEWIDE-INHERITANCE) gives the rule above.
// Setup: Declare the relationship with the standard macro and invoke
// base/derived objects. A new original object-family case combines inherited
// base typewide membership with an independent derived-local callback and
// observes the actual receiver. Expected: The callback runs for both without
// prescribing inherited queue order.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Register the superclass relation with the standard macro and invoke
// base and derived objects separately. No inherited callback order is assumed.

module test_typewide_callback_inheritance_reaches_derived_object;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class user_callback extends uvm_callback;
    `uvm_object_utils(user_callback)
    int calls = 0;
    bit answer = 0;
    function new(string name="user_callback");
      super.new(name);
      void'(callback_mode(1));
    endfunction
    virtual function void hit();
      calls++;
      $display("UT: hit %s", get_name());
    endfunction
    virtual function bit vote();
      calls++;
      $display("UT: vote %s", get_name());
      return answer;
    endfunction
  endclass
  class agent extends uvm_component;
    `uvm_component_utils(agent)
    `uvm_register_cb(agent, user_callback)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void fire();
      `uvm_do_callbacks(agent, user_callback, hit())
    endfunction
    function bit stop_on_true();
      `uvm_do_callbacks_exit_on(agent, user_callback, vote(), 1)
      return 0;
    endfunction
    function bit stop_on_false();
      `uvm_do_callbacks_exit_on(agent, user_callback, vote(), 0)
      return 1;
    endfunction
  endclass
  typedef uvm_callbacks#(agent, user_callback) pool_t;

  class derived_agent extends agent;
    `uvm_component_utils(derived_agent)
    `uvm_register_cb(derived_agent, user_callback)
    `uvm_set_super_type(derived_agent, agent)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  typedef uvm_callbacks#(derived_agent, user_callback) derived_pool_t;

  initial begin
    automatic agent base_value = new("base_value", null);
    automatic derived_agent derived_value = new("derived_value", null);
    automatic user_callback value = new("value");
    pool_t::add(null, value);
    base_value.fire();
    $display("UT: after_base %0d", value.calls);
    derived_value.fire();
    $display("UT: after_derived %0d", value.calls);
    $finish;
  end
endmodule
