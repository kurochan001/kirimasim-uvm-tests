/*
:name: test_packer_byte_array_round_trip_preserves_high_bits
:description: byte array packing preserves zero and high-bit payloads (IEEE 1800.2-2020 Section 16.5.4.10)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.10 16.5.4.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_byte_array_round_trip_preserves_high_bits.expected
*/
// Use the default whole-array size and unpack into an allocated array.
// Observe byte values after round trip without prescribing stream encoding.

module test_packer_byte_array_round_trip_preserves_high_bits;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    uvm_packer packer = new;
    byte source_bytes[] = '{8'h00, 8'h80, 8'hff};
    byte target_bytes[] = new[3];
    packer.pack_bytes(source_bytes);
    packer.unpack_bytes(target_bytes);
    $display("UT: bytes %02h %02h %02h", target_bytes[0], target_bytes[1], target_bytes[2]);
    $finish;
  end
endmodule
