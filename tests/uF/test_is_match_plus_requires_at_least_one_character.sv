/*
:name: test_is_match_plus_requires_at_least_one_character
:description: simplified plus requires one or more characters (IEEE 1800.2-2020 Section F.3.3.1)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_is_match_plus_requires_at_least_one_character.expected
*/
// The pinned UVM_NO_DPI fallback treats plus as a literal character.
// Preserve the one-or-more semantics from Table F.1 as spec-only.
// Simplified notation only; no slash-delimited POSIX expression or DPI.
module test_is_match_plus_requires_at_least_one_character;
  import uvm_pkg::*;
  initial begin

    $display("UT: plus empty %0d one %0d several %0d", uvm_is_match("node+tail", "nodetail"),
    uvm_is_match("node+tail", "nodeXtail"), uvm_is_match("node+tail", "nodeXYZtail"));
    $display("UT: whole prefix %0d suffix %0d", uvm_is_match("node+tail", "prenodeXtail"),
    uvm_is_match("node+tail", "nodeXtailpost"));
    $finish;
  end
endmodule
