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
// What it checks:
// 1. The request/response channel defaults REQ to int.
// 2. The channel defaults RSP to the selected REQ type.
// 3. The request/response channel derives from uvm_component.
// 4. The channel constructor permits an omitted static parent.
// 5. The channel constructor retains the selected component name and parent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.9.1.1 (UVM-TLM-DECL-CHANNEL-DEFAULT-REQ) gives rule 1
//    above. Setup: Construct default int/int, REQ-only string/string and
//    explicit int/string channels, with static or actual component parents.
//    Expected: The default instance fits an exact int/int channel view.
// 2. 1800.2-2020 12.2.9.1.1 (UVM-TLM-DECL-CHANNEL-DEFAULT-RSP) gives rule 2
//    above. Setup: Construct default int/int, REQ-only string/string and
//    explicit int/string channels, with static or actual component parents.
//    Expected: A string-only specialization fits the exact string/string view.
// 3. 1800.2-2020 12.2.9.1.1 (UVM-TLM-DECL-CHANNEL-COMPONENT-BASE) gives rule 3
//    above. Setup: Construct default int/int, REQ-only string/string and
//    explicit int/string channels, with static or actual component parents.
//    Expected: A component view retains the explicit int/string channel
//    identity.
// 4. 1800.2-2020 12.2.9.1.11 (UVM-TLM-DECL-CHANNEL-STATIC-PARENT) gives rule 4
//    above. Setup: Construct default int/int, REQ-only string/string and
//    explicit int/string channels, with static or actual component parents.
//    Expected: The default channel constructs and retains its selected local
//    name.
// 5. 1800.2-2020 12.2.9.1.11 (UVM-TLM-DECL-CHANNEL-NAME-PARENT) gives rule 5
//    above. Setup: Construct default int/int, REQ-only string/string and
//    explicit int/string channels, with static or actual component parents.
//    Expected: Explicit children retain selected local/full names and actual
//    parent identities.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
