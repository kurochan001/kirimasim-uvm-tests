/*
:name: test_pull_and_push_sequencer_omitted_response_types_match_the_request_type
:description: pull and push sequencer omitted response types match the request type
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.5.1 15.6.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pull_and_push_sequencer_omitted_response_types_match_the_request_type.expected
*/
// What it checks:
// 1. The omitted pull request type is uvm_sequence_item.
// 2. The omitted pull response type follows the selected request type.
// 3. The omitted push request type is uvm_sequence_item.
// 4. The omitted push response type follows the selected request type.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.5.1 (UVM-SQR-AUDIT-PULL-DEFAULT-REQUEST) gives rule 1
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: The omitted pull request type
//    is uvm_sequence_item.
// 2. 1800.2-2020 15.5.1 (UVM-SQR-AUDIT-PULL-DEFAULT-RESPONSE) gives rule 2
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: The omitted pull response type
//    follows the selected request type.
// 3. 1800.2-2020 15.6.1 (UVM-SQR-AUDIT-PUSH-DEFAULT-REQUEST) gives rule 3
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: The omitted push request type
//    is uvm_sequence_item.
// 4. 1800.2-2020 15.6.1 (UVM-SQR-AUDIT-PUSH-DEFAULT-RESPONSE) gives rule 4
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: The omitted push response type
//    follows the selected request type.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_pull_and_push_sequencer_omitted_response_types_match_the_request_type;
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
  initial begin
    automatic uvm_sequencer#() pull_default=new("pull_default",null);
    automatic uvm_push_sequencer#() push_default=new("push_default",null);
    automatic uvm_sequencer#(request_item) pull_request=new("pull_request",null);
    automatic uvm_push_sequencer#(request_item) push_request=new("push_request",null);
    automatic uvm_sequencer#(uvm_sequence_item,uvm_sequence_item) pd=pull_default;
    automatic uvm_push_sequencer#(uvm_sequence_item,uvm_sequence_item) sd=push_default;
    automatic uvm_sequencer#(request_item,request_item) pr=pull_request;
    automatic uvm_push_sequencer#(request_item,request_item) sr=push_request;
    $display("UT: sequencer_defaults pull %0d push %0d request_pull %0d request_push %0d",
             pd==pull_default,sd==push_default,pr==pull_request,sr==push_request);
    $finish;
  end
endmodule
