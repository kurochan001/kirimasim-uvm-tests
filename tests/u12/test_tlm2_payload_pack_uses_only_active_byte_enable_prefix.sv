/*
:name: test_tlm2_payload_pack_uses_only_active_byte_enable_prefix
:description: generic payload packing and unpacking preserve the prescribed fields and lengths (IEEE 1800.2-2020 Section 12.3.4.2.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.4 12.3.4.2.5 12.3.4.2.30 12.3.4.2.32 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_pack_uses_only_active_byte_enable_prefix.expected
*/
// What it checks:
// Only the active byte-enable prefix is packed, preserving the following field
// alignment.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.4.2.4 (UVM-TLM2-PAYLOAD-PACK-ENABLE-PREFIX) gives the rule
// above. Setup: Declare two active enable bytes from a three-byte array and
// round-trip the payload. Expected: Enable length two, bytes ff/00 and
// streaming width one are returned.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Pack a two-byte enable pattern from a larger backing array. Check the
// active enable values, length and a following field to expose misalignment.

module test_tlm2_payload_pack_uses_only_active_byte_enable_prefix;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload source = new("source");
    automatic uvm_tlm_generic_payload target = new("target");
    automatic uvm_packer packer = new;
    automatic byte unsigned data_bytes[] = '{8'h21, 8'h43};
    automatic byte unsigned enables[] = '{8'hff, 8'h00, 8'hff};
    byte unsigned decoded[];
    source.set_data(data_bytes);
    source.set_data_length(2);
    source.set_byte_enable(enables);
    source.set_byte_enable_length(2);
    source.set_streaming_width(1);
    source.do_pack(packer);
    target.do_unpack(packer);
    target.get_byte_enable(decoded);
    $display("UT: enable_length %0d prefix %02h %02h width %0d",
             target.get_byte_enable_length(), decoded[0], decoded[1], target.get_streaming_width());
    $finish;
  end
endmodule
