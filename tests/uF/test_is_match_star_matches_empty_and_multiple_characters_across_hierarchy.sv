/*
:name: test_is_match_star_matches_empty_and_multiple_characters_across_hierarchy
:description: simplified star accepts zero or multiple characters and matching is whole-string (IEEE 1800.2-2020 Section F.3.3.1)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_is_match_star_matches_empty_and_multiple_characters_across_hierarchy.expected
*/
// What it checks:
// 1. Simplified star matches zero or more characters, including hierarchy
//    separators.
// 2. Simplified matching requires the complete string rather than an extra
//    prefix or suffix.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.3.3.1 (UVM-MATCH-STAR-ZERO-OR-MORE) gives rule 1 above.
//    Setup: Match adjacent fixed tokens, an inserted word and nested hierarchy
//    text. Expected: All three strings match.
// 2. 1800.2-2020 F.3.3.1 (UVM-MATCH-SIMPLIFIED-WHOLE-STRING) gives rule 2
//    above. Setup: Add an unmatched prefix or suffix outside the fixed ends.
//    Expected: Both extended strings fail to match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Simplified notation only; no slash-delimited POSIX expression or DPI.
module test_is_match_star_matches_empty_and_multiple_characters_across_hierarchy;
  import uvm_pkg::*;
  initial begin

    $display("UT: star empty %0d multiple %0d nested %0d", uvm_is_match("env*agent", "envagent"),
    uvm_is_match("env*agent", "env_alpha_agent"), uvm_is_match("env*agent", "env.sub.agent"));
    $display("UT: whole prefix %0d suffix %0d", uvm_is_match("env*agent", "preenvagent"),
    uvm_is_match("env*agent", "envagentpost"));
    $finish;
  end
endmodule
