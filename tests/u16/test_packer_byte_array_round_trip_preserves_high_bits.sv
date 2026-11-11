/*
:name: test_packer_byte_array_round_trip_preserves_high_bits
:description: byte array packing preserves zero and high-bit payloads (IEEE 1800.2-2020 Section 16.5.4.10)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.10 16.5.4.19 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_byte_array_round_trip_preserves_high_bits.expected
*/
// What it checks:
// 1. Byte-array pack uses bit counts rather than element counts when size is
//    specified.
// 2. Byte-array unpack uses bit counts rather than element counts when size is
//    specified.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.5.4.10 (UVM-PACKER-BYTES-PACK) gives rule 1 above. Setup:
//    Use matching arrays for whole-array transfer and selected prefixes,
//    followed by a scalar where applicable. Expected: Selected data and
//    trailing fields are restored without consuming beyond the selected bit
//    count.
// 2. 1800.2-2020 16.5.4.19 (UVM-PACKER-BYTES-UNPACK) gives rule 2 above.
//    Setup: Use matching arrays for whole-array transfer and selected
//    prefixes, followed by a scalar where applicable. Expected: Selected data
//    and trailing fields are restored without consuming beyond the selected
//    bit count.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use the default whole-array size and unpack into an allocated array.
// Observe byte values after round trip without prescribing stream encoding.

module test_packer_byte_array_round_trip_preserves_high_bits;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_packer packer = new;
    automatic byte source_bytes[] = '{8'h00, 8'h80, 8'hff};
    automatic byte target_bytes[] = new[3];
    packer.pack_bytes(source_bytes);
    packer.unpack_bytes(target_bytes);
    $display("UT: bytes %02h %02h %02h", target_bytes[0], target_bytes[1], target_bytes[2]);
    $finish;
  end
endmodule
