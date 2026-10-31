/*
:name: test_comparer_uses_declared_field_width
:description: integral comparison masks bits above the declared size (IEEE 1800.2-2020 Section 16.3.3.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_uses_declared_field_width.expected
*/
// Only the requested number of bits participates in field comparison.
// Equal low bytes compare equal, while including the differing bits fails.

module test_comparer_uses_declared_field_width;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

initial begin
  automatic uvm_comparer comparer = new;
  bit same;
  same = comparer.compare_field_int("byte", 64'h1207, 64'h3407, 8);
  $display("UT: low byte equal %0d", same);
  same = comparer.compare_field_int("word", 64'h1207, 64'h3407, 16);
  $display("UT: full word equal %0d", same);
  $finish;
end
endmodule
