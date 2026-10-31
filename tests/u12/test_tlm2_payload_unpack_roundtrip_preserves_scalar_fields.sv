/*
:name: test_tlm2_payload_unpack_roundtrip_preserves_scalar_fields
:description: generic payload packing and unpacking preserve the prescribed fields and lengths (IEEE 1800.2-2020 Section 12.3.4.2.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.4 12.3.4.2.5 12.3.4.2.22 12.3.4.2.16 12.3.4.2.35 12.3.4.2.36 12.3.4.2.28 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_unpack_roundtrip_preserves_scalar_fields.expected
*/
// Round-trip an IGNORE payload with empty arrays. Compare scalar values
// through their public accessors without relying on binary stream encoding.

module test_tlm2_payload_unpack_roundtrip_preserves_scalar_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload source = new("source");
    automatic uvm_tlm_generic_payload target = new("target");
    automatic uvm_packer packer = new;
    source.set_address(64'hfedcba9876543210);
    source.set_command(UVM_TLM_IGNORE_COMMAND);
    source.set_dmi_allowed(1);
    source.set_response_status(UVM_TLM_BURST_ERROR_RESPONSE);
    source.set_streaming_width(19);
    source.do_pack(packer);
    target.do_unpack(packer);
    $display("UT: address_same %0d ignore %0d dmi %0d status_same %0d width %0d",
             target.get_address() == source.get_address(), target.get_command() ==
                 UVM_TLM_IGNORE_COMMAND,
             target.is_dmi_allowed(), target.get_response_status() == UVM_TLM_BURST_ERROR_RESPONSE,
             target.get_streaming_width());
    $finish;
  end
endmodule
