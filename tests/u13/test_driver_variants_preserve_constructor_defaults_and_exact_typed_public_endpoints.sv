/*
:name: test_driver_variants_preserve_constructor_defaults_and_exact_typed_public_endpoints
:description: driver variants preserve constructor defaults and exact typed public endpoints
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.7.1 13.7.2.1 13.7.2.2 13.7.3 13.8.1 13.8.2.1 13.8.2.2 13.8.3 13.5.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_driver_variants_preserve_constructor_defaults_and_exact_typed_public_endpoints.expected
*/
module test_driver_variants_preserve_constructor_defaults_and_exact_typed_public_endpoints;
  import uvm_pkg::*;
  class request_item extends uvm_sequence_item; endclass
  class response_item extends uvm_sequence_item; endclass
  class owner_actor extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  initial begin
    automatic owner_actor owner=new("owner46",null);
    automatic uvm_driver default_pull=new("default_pull",owner);
    automatic uvm_push_driver default_push=new("default_push",owner);
    automatic uvm_driver#(request_item) req_pull=new("req_pull",owner);
    automatic uvm_push_driver#(request_item) req_push=new("req_push",owner);
    automatic uvm_driver#(request_item,response_item) pull=new("pull",owner);
    automatic uvm_push_driver#(request_item,response_item) push_value=new("push",owner);
    automatic uvm_driver#(uvm_sequence_item,uvm_sequence_item) default_pull_view=default_pull;
    automatic uvm_push_driver#(uvm_sequence_item,uvm_sequence_item) default_push_view=default_push;
    automatic uvm_driver#(request_item,request_item) req_pull_view=req_pull;
    automatic uvm_push_driver#(request_item,request_item) req_push_view=req_push;
    automatic uvm_seq_item_pull_port#(request_item,response_item) pull_requests=pull.seq_item_port;
    automatic uvm_analysis_port#(response_item) pull_responses=pull.rsp_port;
    automatic uvm_blocking_put_imp#(request_item,
      uvm_push_driver#(request_item,response_item)) push_requests=push_value.req_export;
    automatic uvm_analysis_port#(response_item) push_responses=push_value.rsp_port;
    automatic uvm_component pull_base=pull;
    automatic uvm_component push_base=push_value;
    $display("UT: driver_defaults pull %0d push %0d req_pull %0d req_push %0d",
             default_pull_view==default_pull,default_push_view==default_push,
             req_pull_view==req_pull,req_push_view==req_push);
    $display("UT: driver_constructors pull %0d push %0d bases %0d",
             pull.get_name()=="pull" && pull.get_parent()==owner,
             push_value.get_name()=="push" && push_value.get_parent()==owner,
             pull_base==pull && push_base==push_value);
    $display(
      "UT: driver_endpoints pull_request %0d pull_response %0d push_request %0d push_response %0d",
             pull_requests!=null,pull_responses!=null,push_requests!=null,push_responses!=null);
    // Constructor/type probe only: do not phase an unconnected required port.
    $finish;
  end
endmodule
