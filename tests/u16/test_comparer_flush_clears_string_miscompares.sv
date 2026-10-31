/*
:name: test_comparer_flush_clears_string_miscompares
:description: flushing clears accumulated string miscompares and their counter (IEEE 1800.2-2020 Section 16.3.3.6)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.6 16.3.3.9 16.3.3.8 16.3.2.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_flush_clears_string_miscompares.expected
*/
// Independent failed comparisons accumulate until flush. Check only that
// the miscompare text is empty after reset, not its implementation layout.

module test_comparer_flush_clears_string_miscompares;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    uvm_comparer comparer = new;
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
