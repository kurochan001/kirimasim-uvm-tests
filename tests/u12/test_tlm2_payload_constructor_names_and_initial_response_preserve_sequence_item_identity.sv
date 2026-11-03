/*
:name: test_tlm2_payload_constructor_names_and_initial_response_preserve_sequence_item_identity
:description: tlm2 payload constructor default name and initial response preserve sequence item identity (IEEE 1800.2-2020 Section 12.3.4.2.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.3 12.3.4.2.1 12.3.4.2.11 14.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_constructor_names_and_initial_response_preserve_sequence_item_identity.expected
*/
// Only the declared default/explicit name, sequence-item inheritance and
// stated
// incomplete response default are asserted. Fresh construction preserves a
// preconfigured peer. No unspecified scalar/enum/array default is chosen.
module test_tlm2_payload_constructor_names_and_initial_response_preserve_sequence_item_identity;
  import uvm_pkg::*;
  initial begin
    automatic uvm_tlm_generic_payload peer = new("peer");
    uvm_tlm_generic_payload fresh,named;
    uvm_sequence_item base;
    peer.set_address(64'h123456789abcdef0); peer.set_write();
    peer.set_response_status(UVM_TLM_ADDRESS_ERROR_RESPONSE);
    fresh = new(); named = new("named"); base = fresh;
    $display("UT: payload_constructor name %0d/%0d base %0d incomplete %0d/%0d",
             fresh.get_name() == "",named.get_name() == "named",base == fresh,
             fresh.get_response_status() == UVM_TLM_INCOMPLETE_RESPONSE,
             named.get_response_status() == UVM_TLM_INCOMPLETE_RESPONSE);
    $display("UT: payload_constructor_peer address %0d write %0d status %0d distinct %0d",
             peer.get_address() == 64'h123456789abcdef0,peer.is_write(),
             peer.get_response_status() == UVM_TLM_ADDRESS_ERROR_RESPONSE,
             fresh != named && fresh != peer && named != peer);
    $finish;
  end
endmodule
