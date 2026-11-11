/*
:name: test_is_match_question_requires_exactly_one_character
:description: simplified question mark requires exactly one character (IEEE 1800.2-2020 Section F.3.3.1)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_is_match_question_requires_exactly_one_character.expected
*/
// What it checks:
// Simplified question matches exactly one character.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.3.3.1 (UVM-MATCH-QUESTION-EXACTLY-ONE) gives the rule above.
// Setup: Try zero, one, two and one dot character between fixed ends.
// Expected: Only the one-character and dot strings match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Simplified notation only; no slash-delimited POSIX expression or DPI.
module test_is_match_question_requires_exactly_one_character;
  import uvm_pkg::*;
  initial begin

    $display("UT: question empty %0d one %0d two %0d dot %0d", uvm_is_match("p?q", "pq"),
    uvm_is_match("p?q", "pXq"), uvm_is_match("p?q", "pXYq"), uvm_is_match("p?q", "p.q"));
    $finish;
  end
endmodule
