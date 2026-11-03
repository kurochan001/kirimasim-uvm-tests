/*
:name: test_pull_and_push_common_current_and_outside_history_queries_obey_the_declared_api
:description: pull and push common current and outside history queries obey the declared api
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.4 15.4.1 15.4.2 15.4.3.2 15.6.3.1 15.3.3.2.1 15.3.4.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pull_and_push_common_current_and_outside_history_queries_obey_the_declared_api.expected
*/
module test_pull_and_push_common_current_and_outside_history_queries_obey_the_declared_api;
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
    automatic uvm_sequencer#(request_item,response_item) pull=new("pull",null);
    automatic uvm_push_sequencer#(request_item,response_item) push=new("push",null);
    pull.set_num_last_reqs(1); pull.set_num_last_rsps(1);
    push.set_num_last_reqs(1); push.set_num_last_rsps(1);
    $display("UT: common_current pull %0d push %0d",
             pull.get_current_item()==null,push.get_current_item()==null);
    $display("UT: common_outside_history pull_req %0d pull_rsp %0d push_req %0d push_rsp %0d",
             pull.last_req(2)==null,pull.last_rsp(2)==null,
             push.last_req(2)==null,push.last_rsp(2)==null);
    $finish;
  end
endmodule
