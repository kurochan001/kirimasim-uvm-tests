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
// What it checks:
// 1. The transport channel defaults REQ to int.
// 2. The transport channel defaults RSP to REQ.
// 3. The transport channel derives from its matching request/response channel.
// 4. The transport constructor permits omitted parent for static use.
// 5. The transport constructor retains its selected component name and parent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.9.2.1 (UVM-TLM-DECL-TRANSPORT-DEFAULT-REQ) gives rule 1
//    above. Setup: Construct default and REQ-only transport channels,
//    assigning exact request/response parent views and explicit parents.
//    Expected: The exact int/int transport view retains identity.
// 2. 1800.2-2020 12.2.9.2.1 (UVM-TLM-DECL-TRANSPORT-DEFAULT-RSP) gives rule 2
//    above. Setup: Construct default and REQ-only transport channels,
//    assigning exact request/response parent views and explicit parents.
//    Expected: The REQ-only string channel fits the exact string/string parent
//    view.
// 3. 1800.2-2020 12.2.9.2.1 (UVM-TLM-DECL-TRANSPORT-CHANNEL-BASE) gives rule 3
//    above. Setup: Construct default and REQ-only transport channels,
//    assigning exact request/response parent views and explicit parents.
//    Expected: REQ-only and distinct-type exact parent views retain channel
//    identity.
// 4. 1800.2-2020 12.2.9.2.3 (UVM-TLM-DECL-TRANSPORT-STATIC-PARENT) gives rule
//    4 above. Setup: Construct default and REQ-only transport channels,
//    assigning exact request/response parent views and explicit parents.
//    Expected: Construction succeeds and the local name is retained.
// 5. 1800.2-2020 12.2.9.2.3 (UVM-TLM-DECL-TRANSPORT-NAME-PARENT) gives rule 5
//    above. Setup: Construct default and REQ-only transport channels,
//    assigning exact request/response parent views and explicit parents.
//    Expected: Explicit children retain names and actual parent identities.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
