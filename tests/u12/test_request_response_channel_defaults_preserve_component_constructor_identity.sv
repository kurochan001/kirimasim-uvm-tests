/*
:name: test_request_response_channel_defaults_preserve_component_constructor_identity
:description: request response channel defaults and specializations preserve component constructor identity (IEEE 1800.2-2020 Section 12.2.9.1.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.1.1 12.2.9.1.11 13.1.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_request_response_channel_defaults_preserve_component_constructor_identity.expected
*/
// Check exact default/REQ-only/distinct channel types before binding
// resolution.
// The static channel omits parent; explicit children retain actual
// names/parents.
// No constructor probe alone establishes queue capacities or resolved binding.
module test_request_response_channel_defaults_preserve_component_constructor_identity;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(); super.new("owner",null); endfunction
  endclass
  initial begin
    automatic owner parent_value = new();
    automatic uvm_tlm_req_rsp_channel#() standalone = new("standalone");
    automatic uvm_tlm_req_rsp_channel#(string) child = new("child",parent_value);
    automatic uvm_tlm_req_rsp_channel#(int,string) distinct = new("distinct",parent_value,2,3);
    automatic uvm_tlm_req_rsp_channel#(int,int) exact_default = standalone;
    automatic uvm_tlm_req_rsp_channel#(string,string) inherited_response = child;
    automatic uvm_component base = distinct;
    $display("UT: channel_types defaults %0d inherited_response %0d component %0d",
             exact_default == standalone,inherited_response == child,base == distinct);
    $display("UT: channel_names standalone %0d child %0d distinct %0d parent %0d",
             standalone.get_name() == "standalone",child.get_full_name() == "owner.child",
             distinct.get_name() == "distinct",child.get_parent() == parent_value &&
             distinct.get_parent() == parent_value);
    $finish;
  end
endmodule
