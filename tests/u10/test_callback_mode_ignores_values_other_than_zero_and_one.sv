/*
:name: test_callback_mode_ignores_values_other_than_zero_and_one
:description: callback mode arguments other than zero and one preserve enable state (IEEE 1800.2-2020 Section 10.7.1.2.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.1.2.2 10.7.1.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_mode_ignores_values_other_than_zero_and_one.expected
*/
// Query both disabled and enabled states with explicit out-of-range
// arguments. The return value remains the prior enable state.

module test_callback_mode_ignores_values_other_than_zero_and_one;
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
    automatic user_callback value = new("value");
    bit previous;
    void'(value.callback_mode(0));
    previous = value.callback_mode(7);
    $display("UT: ignored_disabled previous %0d enabled %0d", previous, value.is_enabled());
    void'(value.callback_mode(1));
    previous = value.callback_mode(-7);
    $display("UT: ignored_enabled previous %0d enabled %0d", previous, value.is_enabled());
    $finish;
  end
endmodule
