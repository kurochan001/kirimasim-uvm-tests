/*
:name: test_callbacks_optional_callback_parameter_add_and_delete_reach_the_typed_dispatch
:description: callbacks optional callback parameter add and delete reach the registered typed dispatch (IEEE 1800.2-2020 Section 10.7.2.2.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.2.2 10.7.2.2.1 10.7.2.3.1 10.7.2.3.3 10.7.2.5 B.4.1 B.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callbacks_optional_callback_parameter_add_and_delete_reach_the_typed_dispatch.expected
*/
// Register a valid original object/callback pair, then omit only CB when using
// add/delete. Typed enumeration and the standard typed dispatch macro observe
// the actual shared registration. No invalid-pair diagnostic, omitted T
// registration, private pool or default enable state is assumed.
module test_callbacks_optional_callback_parameter_add_and_delete_reach_the_typed_dispatch;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class callback_type extends uvm_callback;
    `uvm_object_utils(callback_type)
    int calls = 0;
    function new(string name = "callback"); super.new(name); void'(callback_mode(1)); endfunction
    virtual function void hit(); calls++; endfunction
  endclass
  class agent extends uvm_component;
    `uvm_component_utils(agent)
    `uvm_register_cb(agent,callback_type)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void fire(); `uvm_do_callbacks(agent,callback_type,hit()) endfunction
  endclass
  initial begin
    automatic agent context_value = new("context_value",null);
    automatic callback_type callback_value = new();
    callback_type entries[$];
    uvm_callbacks#(agent)::add(context_value,callback_value);
    uvm_callbacks#(agent,callback_type)::get_all(entries,context_value);
    context_value.fire();
    $display("UT: optional_cb_added entries %0d identity %0d calls %0d",entries.size(),
             entries.size() == 1 && entries[0] == callback_value,callback_value.calls);
    uvm_callbacks#(agent)::delete(context_value,callback_value); entries.delete();
    uvm_callbacks#(agent,callback_type)::get_all(entries,context_value);
    context_value.fire();
    $display("UT: optional_cb_deleted entries %0d calls %0d",entries.size(),callback_value.calls);
    $finish;
  end
endmodule
