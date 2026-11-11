/*
:name: test_typewide_callback_delete_preserves_derived_instance_registration
:description: deleting a base typewide callback retains a derived instance callback (IEEE 1800.2-2020 Section 10.7.2.3.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.3.3 10.7.2.3.1 B.4.2 B.4.1 B.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_typewide_callback_delete_preserves_derived_instance_registration.expected
*/
// What it checks:
// Callback deletion removes the selected context registration while retaining
// independent registrations.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.7.2.3.3 (UVM-CALLBACK-DELETE-REGISTRATION) gives the rule
// above. Setup: Delete from an instance or the typewide queue while sharing
// handles or retaining local/derived entries. Expected: Removed registrations
// no longer execute and independent entries still do.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Install the instance callback through the registered derived type
// pair. Delete the inherited global callback before invoking either object.

module test_typewide_callback_delete_preserves_derived_instance_registration;
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
    automatic user_callback typewide = new("typewide");
    automatic user_callback local_value = new("local_value");
    pool_t::add(null, typewide);
    derived_pool_t::add(derived_value, local_value);
    pool_t::delete(null, typewide);
    base_value.fire();
    derived_value.fire();
    $display("UT: counts global %0d local %0d", typewide.calls, local_value.calls);
    $finish;
  end
endmodule
