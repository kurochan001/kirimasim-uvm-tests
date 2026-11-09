/*
:name: test_sequencer_interface_explicit_request_and_response_views_preserve_exact_identity
:description: sequencer interface explicit request and response views preserve exact identity
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.2.1.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_interface_explicit_request_and_response_views_preserve_exact_identity.expected
*/
// What it checks:
// 1. An omitted interface response type follows its explicit request type.
// 2. A legal interface subtype supports distinct request and response types
//    derived from sequence items.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.2.1.1 (UVM-SQR-AUDIT-INTERFACE-DEFAULT-RESPONSE) gives
//    rule 1 above. Setup: Use the selected original fixture, declared type
//    arguments, public endpoint/base views and linked stage observations.
//    Requests satisfy the grant precondition before send_request and response
//    IDs are copied from the actual request. Expected: An omitted interface
//    response type follows its explicit request type.
// 2. 1800.2-2020 15.2.1.1 (UVM-SQR-AUDIT-INTERFACE-EXPLICIT-TYPES) gives rule
//    2 above. Setup: Use the selected original fixture, declared type
//    arguments, public endpoint/base views and linked stage observations.
//    Requests satisfy the grant precondition before send_request and response
//    IDs are copied from the actual request. Expected: A legal interface
//    subtype supports distinct request and response types derived from
//    sequence items.
// It also supports, as a control, the setup or conditions of
// UVM-SQR-AUDIT-UVM-SQR-IF-BASE-ABSTRACT.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequencer_interface_explicit_request_and_response_views_preserve_exact_identity;
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
  class request_interface extends uvm_sqr_if_base#(request_item); endclass
  class split_interface extends uvm_sqr_if_base#(request_item,response_item); endclass
  initial begin
    automatic request_interface request_value=new();
    automatic split_interface split_value=new();
    automatic uvm_sqr_if_base#(request_item,request_item) request_view=request_value;
    automatic uvm_sqr_if_base#(request_item,response_item) split_view=split_value;
    $display("UT: explicit_interface inherited_response %0d split %0d",
             request_view==request_value,split_view==split_value);
    $finish;
  end
endmodule
