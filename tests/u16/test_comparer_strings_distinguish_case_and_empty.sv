/*
:name: test_comparer_strings_distinguish_case_and_empty
:description: string comparison handles empty strings and case differences (IEEE 1800.2-2020 Section 16.3.3.6)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.6 16.3.3.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_strings_distinguish_case_and_empty.expected
*/
// What it checks:
// String comparison distinguishes differing strings, including character case.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.3.3.6 (UVM-COMPARER-STRING-VALUE) gives the rule above.
// Setup: Compare empty/equal strings and case-differing strings with
// controlled reuse. Expected: Equal empty strings succeed and differing
// strings increase mismatch state.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Equal empty strings compare equal. A difference in character case is a
// miscompare; observe the boolean and counter, not diagnostic formatting.

module test_comparer_strings_distinguish_case_and_empty;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_comparer comparer = new;
    bit same;
    same = comparer.compare_string("empty", "", "");
    $display("UT: empty equal %0d count %0d", same, comparer.get_result());
    same = comparer.compare_string("case", "Ready", "ready");
    $display("UT: case equal %0d count %0d", same, comparer.get_result());
    $finish;
  end
endmodule
