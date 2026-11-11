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
// What it checks:
// 1. The registry accepts an object-derived associated context type.
// 2. The registry accepts a callback-derived interface type.
// 3. The CB parameter may be omitted when using callback add/delete
//    interfaces.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.7.2.2.1 (UVM-OBJECTION-CB-REVIEW-CALLBACKS-OBJECT-TYPE)
//    gives rule 1 above. Setup: Use original context/callback subtypes and a
//    valid macro-registered pair. Expected: The selected typed registry
//    constructs and a registered component context accepts actual callback
//    dispatch.
// 2. 1800.2-2020 10.7.2.2.2 (UVM-OBJECTION-CB-REVIEW-CALLBACKS-CALLBACK-TYPE)
//    gives rule 2 above. Setup: Use original context/callback subtypes and a
//    valid macro-registered pair. Expected: The selected interface type
//    constructs, enumerates the supplied callback and dispatches its original
//    hook.
// 3. 1800.2-2020 10.7.2.2.2 (UVM-OBJECTION-CB-REVIEW-OPTIONAL-CB-ADD-DELETE)
//    gives rule 3 above. Setup: Register an original valid pair and use only T
//    in add/delete, with typed enumeration and dispatch. Expected: Typed
//    get_all sees the same callback and one hook invocation; deletion removes
//    registration without another invocation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
