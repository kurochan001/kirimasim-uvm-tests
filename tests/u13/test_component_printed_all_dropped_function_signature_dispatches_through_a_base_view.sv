/*
:name: test_component_printed_all_dropped_function_signature_dispatches_through_a_base_view
:description: component printed all dropped function signature dispatches through a base view
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.6.3 10.5.1.4.3 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_printed_all_dropped_function_signature_dispatches_through_a_base_view.expected
*/
// What it checks:
// The printed component all_dropped function declaration supports its selected
// nonblocking override and function caller.
//
// How the expected output follows from the standard:
// 1800.2-2020 13.1.6.3 (UVM-COMPONENT-EXT-PRINTED-ALL-DROPPED-FUNCTION) gives
// the rule above. Setup: Use the linked original fixtures and their explicit
// public phase, factory or hierarchy calls. Preserve the declared original
// types, scope, arguments and expected observations; no private implementation
// state supplies an oracle. Expected: The printed component all_dropped
// function declaration supports its selected nonblocking override and function
// caller.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_component_printed_all_dropped_function_signature_dispatches_through_a_base_view;
  import uvm_pkg::*;
  class hook_actor extends uvm_component;
    int calls=0;
    bit context_ok=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function void all_dropped(uvm_objection objection,uvm_object source_obj,
                                      string description,int count);
      calls++; context_ok=objection!=null && source_obj==this;
      context_ok &= description=="printed47" && count==2;
    endfunction
  endclass
  function automatic void invoke_printed(uvm_component view,uvm_objection objection);
    view.all_dropped(objection,view,"printed47",2);
  endfunction
  initial begin
    automatic hook_actor actor=new("actor47",null);
    automatic uvm_objection objection=new("objection47");
    invoke_printed(actor,objection);
    $display("UT: printed_all_dropped calls %0d context %0d",actor.calls,actor.context_ok);
    $finish;
  end
endmodule
