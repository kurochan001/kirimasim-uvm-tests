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
// What it checks:
// 1. The selected pull driver is usable through uvm_component.
// 2. The omitted pull driver request type is uvm_sequence_item.
// 3. The omitted pull driver response type follows its selected request type.
// 4. The pull driver constructor preserves its supplied name and component
//    parent.
// 5. The pull driver creates its declared exact request/response-specific
//    request endpoint.
// 6. The pull driver creates its declared exact request/response-specific
//    response analysis port.
// 7. The selected push driver is usable through uvm_component.
// 8. The omitted push driver request type is uvm_sequence_item.
// 9. The omitted push driver response type follows its selected request type.
// 10. The push driver constructor preserves its supplied name and component
//     parent.
// 11. The push driver creates its declared exact request/response-specific
//     request endpoint.
// 12. The push driver creates its declared exact request/response-specific
//     response analysis port.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.7.1 (UVM-COMPONENT-AUDIT-PULL-DRIVER-BASE-TYPE) gives rule
//    1 above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: The selected pull driver is usable through
//    uvm_component.
// 2. 1800.2-2020 13.7.1 (UVM-COMPONENT-AUDIT-PULL-DRIVER-DEFAULT-REQUEST)
//    gives rule 2 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The omitted pull driver request type is
//    uvm_sequence_item.
// 3. 1800.2-2020 13.7.1 (UVM-COMPONENT-AUDIT-PULL-DRIVER-DEFAULT-RESPONSE)
//    gives rule 3 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The omitted pull driver response type
//    follows its selected request type.
// 4. 1800.2-2020 13.7.3 (UVM-COMPONENT-AUDIT-PULL-DRIVER-CONSTRUCTOR) gives
//    rule 4 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The pull driver constructor preserves
//    its supplied name and component parent.
// 5. 1800.2-2020 13.7.2.1 (UVM-COMPONENT-AUDIT-PULL-DRIVER-REQUEST-TYPE) gives
//    rule 5 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The pull driver creates its declared
//    exact request/response-specific request endpoint.
// 6. 1800.2-2020 13.7.2.2 (UVM-COMPONENT-AUDIT-PULL-DRIVER-RESPONSE-TYPE)
//    gives rule 6 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The pull driver creates its declared
//    exact request/response-specific response analysis port.
// 7. 1800.2-2020 13.8.1 (UVM-COMPONENT-AUDIT-PUSH-DRIVER-BASE-TYPE) gives rule
//    7 above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: The selected push driver is usable through
//    uvm_component.
// 8. 1800.2-2020 13.8.1 (UVM-COMPONENT-AUDIT-PUSH-DRIVER-DEFAULT-REQUEST)
//    gives rule 8 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The omitted push driver request type is
//    uvm_sequence_item.
// 9. 1800.2-2020 13.8.1 (UVM-COMPONENT-AUDIT-PUSH-DRIVER-DEFAULT-RESPONSE)
//    gives rule 9 above. Setup: Use the selected original concrete component
//    subtypes, legal unique names, declared public types and linked
//    observations. Construct the hierarchy before phasing where phase
//    callbacks are observed. Expected: The omitted push driver response type
//    follows its selected request type.
// 10. 1800.2-2020 13.8.3 (UVM-COMPONENT-AUDIT-PUSH-DRIVER-CONSTRUCTOR) gives
//     rule 10 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: The push driver constructor preserves
//     its supplied name and component parent.
// 11. 1800.2-2020 13.8.2.1 (UVM-COMPONENT-AUDIT-PUSH-DRIVER-REQUEST-TYPE)
//     gives rule 11 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: The push driver creates its declared
//     exact request/response-specific request endpoint.
// 12. 1800.2-2020 13.8.2.2 (UVM-COMPONENT-AUDIT-PUSH-DRIVER-RESPONSE-TYPE)
//     gives rule 12 above. Setup: Use the selected original concrete component
//     subtypes, legal unique names, declared public types and linked
//     observations. Construct the hierarchy before phasing where phase
//     callbacks are observed. Expected: The push driver creates its declared
//     exact request/response-specific response analysis port.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
