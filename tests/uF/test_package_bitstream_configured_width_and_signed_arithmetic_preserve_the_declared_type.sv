/*
:name: test_package_bitstream_configured_width_and_signed_arithmetic_preserve_the_declared_type
:description: The bitstream type uses the selected stream width and signed arithmetic
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.1.3 B.6.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:uvm_defines: UVM_MAX_STREAMBITS=257
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_bitstream_configured_width_and_signed_arithmetic_preserve_the_declared_type.expected
*/
// What it checks:
// 1. The bitstream type follows the selected stream width and signed
//    arithmetic.
// 2. The selected stream configuration produces 257 bitstream bits.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.2.1.3 (UVM-PACKAGE-AUDIT-BITSTREAM-TYPE) gives rule 1
//    above. Setup: Separate default and explicit 257-bit macro conditions use
//    negative all-one and high-bit-only values. Expected: Width equals the
//    macro; negative comparisons and stored arithmetic sign extension hold,
//    and shifting the top-bit-only value left clears it.
// 2. 1800.2-2020 B.6.2 (UVM-PACKAGE-AUDIT-STREAM-OVERRIDE) gives rule 2 above.
//    Setup: Default macro omission or explicit UVM_MAX_STREAMBITS=257,
//    measured in separate compilation units. Expected: The concrete type width
//    equals 257, rather than merely comparing the type to an unconstrained
//    macro.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Two-state width and signedness only; X/Z preservation remains separate.
`include "uvm_macros.svh"
module test_package_bitstream_configured_width_and_signed_arithmetic_preserve_the_declared_type;
  import uvm_pkg::*;
  initial begin
    automatic uvm_bitstream_t negative=-1;
    automatic uvm_bitstream_t shifted=negative >>> 1;
    $display("UT: bitstream width %0d negative %0d arithmetic_sign %0d",
      $bits(negative)==`UVM_MAX_STREAMBITS,negative<0,shifted==negative);
    negative='0; negative[`UVM_MAX_STREAMBITS-1]=1;
    $display("UT: bitstream top_bit_negative %0d lower_bits_zero %0d",negative<0,
      (negative << 1)==0);
    $display("UT: bitstream selected_width %0d",$bits(negative)==257);
    $finish;
  end
endmodule
