/*
:name: test_transport_channel_defaults_and_request_only_response_preserve_base_identity
:description: transport channel default types and request only response preserve declared base identity (IEEE 1800.2-2020 Section 12.2.9.2.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.2.1 12.2.9.2.3 12.2.9.1.1 13.1.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transport_channel_defaults_and_request_only_response_preserve_base_identity.expected
*/
// The channel RSP default is REQ, unlike the regular port summary default.
// Exact subtype/base assignments check defaults and explicit distinct types.
// Constructor checks precede elaboration; transport behavior has separate
// tests.
module test_transport_channel_defaults_and_request_only_response_preserve_base_identity;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(); super.new("owner",null); endfunction
  endclass
  initial begin
    automatic owner parent_value = new();
    automatic uvm_tlm_transport_channel#() standalone = new("standalone");
    automatic uvm_tlm_transport_channel#(string) child = new("child",parent_value);
    automatic uvm_tlm_transport_channel#(int,string) distinct = new("distinct",parent_value);
    automatic uvm_tlm_transport_channel#(int,int) default_view = standalone;
    automatic uvm_tlm_req_rsp_channel#(string,string) parent_view = child;
    automatic uvm_tlm_req_rsp_channel#(int,string) distinct_view = distinct;
    $display("UT: transport_types defaults %0d inherited_response %0d distinct_base %0d",
             default_view == standalone,parent_view == child,distinct_view == distinct);
    $display("UT: transport_names standalone %0d child %0d distinct %0d parent %0d",
             standalone.get_name() == "standalone",child.get_full_name() == "owner.child",
             distinct.get_name() == "distinct",child.get_parent() == parent_value &&
             distinct.get_parent() == parent_value);
    $finish;
  end
endmodule
