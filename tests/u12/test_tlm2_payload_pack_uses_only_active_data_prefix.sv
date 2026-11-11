/*
:name: test_tlm2_payload_pack_uses_only_active_data_prefix
:description: generic payload packing and unpacking preserve the prescribed fields and lengths (IEEE 1800.2-2020 Section 12.3.4.2.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.4 12.3.4.2.5 12.3.4.2.24 12.3.4.2.26 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_pack_uses_only_active_data_prefix.expected
*/
// What it checks:
// Only the active data prefix is packed without modifying the source backing
// array.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.4.2.4 (UVM-TLM2-PAYLOAD-PACK-DATA-PREFIX) gives the rule
// above. Setup: Supply four bytes but declare two, then unpack into a fresh
// payload. Expected: Decoded length/prefix are two and 00/fe hex; original
// size is four and tail remains 93 hex.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Provide four backing bytes but declare two active bytes. Unpack into a
// fresh payload and inspect the active prefix and unchanged source array.

module test_tlm2_payload_pack_uses_only_active_data_prefix;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload source = new("source");
    automatic uvm_tlm_generic_payload target = new("target");
    automatic uvm_packer packer = new;
    automatic byte unsigned data_bytes[] = '{8'h00, 8'hfe, 8'h71, 8'h93};
    byte unsigned decoded[];
    byte unsigned original[];
    source.set_command(UVM_TLM_READ_COMMAND);
    source.set_data(data_bytes);
    source.set_data_length(2);
    source.do_pack(packer);
    target.do_unpack(packer);
    target.get_data(decoded);
    source.get_data(original);
    $display("UT: length %0d prefix %02h %02h source_size %0d source_tail %02h",
             target.get_data_length(), decoded[0], decoded[1], original.size(), original[3]);
    $finish;
  end
endmodule
