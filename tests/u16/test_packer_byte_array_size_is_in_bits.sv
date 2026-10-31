/*
:name: test_packer_byte_array_size_is_in_bits
:description: byte array size selects a bit count and preserves the following scalar (IEEE 1800.2-2020 Section 16.5.4.10)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.10 16.5.4.19 16.5.4.9 16.5.4.17
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_byte_array_size_is_in_bits.expected
*/
// A size of sixteen selects two complete bytes from a longer source.
// The next scalar follows those sixteen bits and is unpacked independently.

module test_packer_byte_array_size_is_in_bits;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    uvm_packer packer = new;
    byte source_bytes[] = '{8'h12, 8'hf3, 8'h7e};
    byte target_bytes[] = new[2];
    int trailer;
    packer.pack_bytes(source_bytes, 16);
    packer.pack_field_int(5, 3);
    packer.unpack_bytes(target_bytes, 16);
    trailer = int'(packer.unpack_field_int(3));
    $display("UT: prefix %02h %02h trailer %0d", target_bytes[0], target_bytes[1], trailer);
    $finish;
  end
endmodule
