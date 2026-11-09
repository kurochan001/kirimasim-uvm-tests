/*
:name: test_sequencer_interface_defaults_and_selected_legal_subtypes_keep_exact_base_types
:description: sequencer interface defaults and selected legal subtypes keep exact base types
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.2.1.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_interface_defaults_and_selected_legal_subtypes_keep_exact_base_types.expected
*/
// What it checks:
// The omitted interface request type is uvm_sequence_item.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.2.1.1 (UVM-SQR-AUDIT-INTERFACE-DEFAULT-REQUEST) gives the
// rule above. Setup: Use the selected original fixture, declared type
// arguments, public endpoint/base views and linked stage observations.
// Requests satisfy the grant precondition before send_request and response IDs
// are copied from the actual request. Expected: The omitted interface request
// type is uvm_sequence_item.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequencer_interface_defaults_and_selected_legal_subtypes_keep_exact_base_types;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class request_item extends uvm_sequence_item;
    `uvm_object_utils(request_item)
    int value=45;
    function new(string name="request"); super.new(name); endfunction
  endclass
  class response_item extends uvm_sequence_item;
    `uvm_object_utils(response_item)
    int value=145;
    function new(string name="response"); super.new(name); endfunction
  endclass
  class default_interface extends uvm_sqr_if_base#(); endclass
  class request_interface extends uvm_sqr_if_base#(request_item); endclass
  class split_interface extends uvm_sqr_if_base#(request_item,response_item); endclass
  initial begin
    automatic default_interface default_value=new();
    automatic request_interface request_value=new();
    automatic split_interface split_value=new();
    automatic uvm_sqr_if_base#(uvm_sequence_item,uvm_sequence_item) default_view=default_value;
    automatic uvm_sqr_if_base#(request_item,request_item) request_view=request_value;
    automatic uvm_sqr_if_base#(request_item,response_item) split_view=split_value;
    $display("UT: interface_types default %0d inherited_response %0d split %0d",
             default_view==default_value,request_view==request_value,split_view==split_value);
    $finish;
  end
endmodule
