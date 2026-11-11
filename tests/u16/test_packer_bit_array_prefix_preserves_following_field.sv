/*
:name: test_packer_bit_array_prefix_preserves_following_field
:description: bit array size limits the packed prefix without consuming the following field (IEEE 1800.2-2020 Section 16.5.4.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.1 16.5.4.18 16.5.4.9 16.5.4.17 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_bit_array_prefix_preserves_following_field.expected
*/
// What it checks:
// 1. Bit-array pack uses bit counts rather than element counts when size is
//    specified.
// 2. Bit-array unpack uses bit counts rather than element counts when size is
//    specified.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.5.4.1 (UVM-PACKER-BITS-PACK) gives rule 1 above. Setup:
//    Use matching arrays for whole-array transfer and selected prefixes,
//    followed by a scalar where applicable. Expected: Selected data and
//    trailing fields are restored without consuming beyond the selected bit
//    count.
// 2. 1800.2-2020 16.5.4.18 (UVM-PACKER-BITS-UNPACK) gives rule 2 above. Setup:
//    Use matching arrays for whole-array transfer and selected prefixes,
//    followed by a scalar where applicable. Expected: Selected data and
//    trailing fields are restored without consuming beyond the selected bit
//    count.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Pack a prefix shorter than the source array and then a scalar. Unpack
// both to observe array indexing and the boundary between the two fields.

module test_packer_bit_array_prefix_preserves_following_field;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_packer packer = new;
    automatic bit source_bits[] = '{1, 0, 1, 1, 0};
    automatic bit target_bits[] = new[3];
    int trailer;
    packer.pack_bits(source_bits, 3);
    packer.pack_field_int(10, 4);
    packer.unpack_bits(target_bits, 3);
    trailer = int'(packer.unpack_field_int(4));
    $display("UT: prefix %0d%0d%0d trailer %0d", target_bits[0], target_bits[1],
             target_bits[2], trailer);
    $finish;
  end
endmodule
