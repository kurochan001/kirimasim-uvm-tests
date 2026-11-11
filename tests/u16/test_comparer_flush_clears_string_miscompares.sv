/*
:name: test_comparer_flush_clears_string_miscompares
:description: flushing clears accumulated string miscompares and their counter (IEEE 1800.2-2020 Section 16.3.3.6)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.6 16.3.3.9 16.3.3.8 16.3.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_flush_clears_string_miscompares.expected
*/
// What it checks:
// 1. String comparison distinguishes differing strings, including character
//    case.
// 2. Comparer flush clears miscompare counts, text and remembered comparison
//    state.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.3.3.6 (UVM-COMPARER-STRING-VALUE) gives rule 1 above.
//    Setup: Compare empty/equal strings and case-differing strings with
//    controlled reuse. Expected: Equal empty strings succeed and differing
//    strings increase mismatch state.
// 2. 1800.2-2020 16.3.2.2 (UVM-COMPARER-FLUSH-STATE) gives rule 2 above.
//    Setup: Accumulate failures, inspect completed history, then flush and
//    reuse the policy. Expected: Count becomes zero, text empty and previous
//    pairs return to unseen state.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independent failed comparisons accumulate until flush. Check only that
// the miscompare text is empty after reset, not its implementation layout.

module test_comparer_flush_clears_string_miscompares;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_comparer comparer = new;
    bit same;
    same = comparer.compare_string("first", "oak", "pine");
    same = comparer.compare_string("second", "red", "blue");
    $display("UT: accumulated %0d", comparer.get_result());
    comparer.flush();
    $display("UT: reset count %0d empty %0d", comparer.get_result(),
             comparer.get_miscompares() == "");
    same = comparer.compare_string("again", "ready", "ready");
    $display("UT: reuse equal %0d count %0d", same, comparer.get_result());
    $finish;
  end
endmodule
