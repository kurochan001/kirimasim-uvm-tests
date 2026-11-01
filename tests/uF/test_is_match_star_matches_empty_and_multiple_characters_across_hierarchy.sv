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
