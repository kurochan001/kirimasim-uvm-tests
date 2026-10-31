/*
:name: test_comparer_real_zero_and_flush_reset_result
:description: real zero compares equal and comparer flush discards an earlier real mismatch (IEEE 1800.2-2020 Section 16.3.3.3)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.3 16.3.2.2 16.3.3.9
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_real_zero_and_flush_reset_result.expected
*/
// After a finite real mismatch, flush the policy and compare two zero
// values. No NaN, infinity, tolerance or textual formatting rule is assumed.

module test_comparer_real_zero_and_flush_reset_result;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_comparer comparer = new;
    bit different_value;
    bit zero_value;
    comparer.set_show_max(0);
    different_value = comparer.compare_field_real("different", -1.0, 1.0);
    $display("UT: different %0d mismatches %0d", different_value, comparer.get_result());
    comparer.flush();
    zero_value = comparer.compare_field_real("zero", 0.0, -0.0);
    $display("UT: zero_equal %0d mismatches %0d", zero_value, comparer.get_result());
    $finish;
  end
endmodule
