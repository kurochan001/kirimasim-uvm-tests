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
