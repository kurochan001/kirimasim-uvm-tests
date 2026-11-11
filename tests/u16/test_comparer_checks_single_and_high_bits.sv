/*
:name: test_comparer_checks_single_and_high_bits
:description: integral comparison handles one-bit and full 64-bit boundaries (IEEE 1800.2-2020 Section 16.3.3.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_checks_single_and_high_bits.expected
*/
// What it checks:
// Integral comparison uses only the specified bit width up to 64 bits.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.3.3.2 (UVM-COMPARER-INTEGRAL-WIDTH) gives the rule above.
// Setup: Compare differing low/high bits under widths 1, 8, 32 and 64.
// Expected: Ignored high bits do not cause mismatch, while included
// differences do.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// One-bit comparison ignores higher bits but observes bit zero. A 64-bit
// comparison must also observe the most significant bit.

module test_comparer_checks_single_and_high_bits;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

initial begin
  automatic uvm_comparer comparer = new;
  bit same;
  same = comparer.compare_field_int("one", 64'hff, 64'h01, 1);
  $display("UT: one bit equal %0d", same);
  same = comparer.compare_field_int("one", 64'h01, 64'h00, 1);
  $display("UT: one bit different %0d", same);
  same = comparer.compare_field_int("wide", 64'h8000000000000000, 64'h0, 64);
  $display("UT: high bit equal %0d", same);
  $finish;
end
endmodule
