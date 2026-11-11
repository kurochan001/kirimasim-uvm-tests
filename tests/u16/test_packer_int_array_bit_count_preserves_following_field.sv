/*
:name: test_packer_int_array_bit_count_preserves_following_field
:description: an integer array bit count selects its prefix and leaves the following field aligned (IEEE 1800.2-2020 Section 16.5.4.11)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.11 16.5.4.12 16.5.4.9 16.5.4.17
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_int_array_bit_count_preserves_following_field.expected
*/
// What it checks:
// 1. Int-array pack uses bit counts rather than element counts when size is
//    specified.
// 2. Int-array unpack uses bit counts rather than element counts when size is
//    specified.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.5.4.11 (UVM-PACKER-INTS-PACK) gives rule 1 above. Setup:
//    Use matching arrays for whole-array transfer and selected prefixes,
//    followed by a scalar where applicable. Expected: Selected data and
//    trailing fields are restored without consuming beyond the selected bit
//    count.
// 2. 1800.2-2020 16.5.4.12 (UVM-PACKER-INTS-UNPACK) gives rule 2 above. Setup:
//    Use matching arrays for whole-array transfer and selected prefixes,
//    followed by a scalar where applicable. Expected: Selected data and
//    trailing fields are restored without consuming beyond the selected bit
//    count.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A size of sixty-four selects two integers from a three-element array.
// The next seven-bit field must follow those two integers without the third.

module test_packer_int_array_bit_count_preserves_following_field;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_packer packer = new;
    automatic int source_values[] = '{32'h12345678, 32'hf00000ab, 32'hdeadbeef};
    automatic int target_values[] = new[2];
    int trailer;
    packer.pack_ints(source_values, 64);
    packer.pack_field_int(85, 7);
    packer.unpack_ints(target_values, 64);
    trailer = int'(packer.unpack_field_int(7));
    $display("UT: prefix %08h %08h trailer %0d", target_values[0], target_values[1], trailer);
    $finish;
  end
endmodule
