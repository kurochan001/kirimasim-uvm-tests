/*
:name: test_is_match_simplified_nonmetacharacters_are_literal
:description: simplified notation treats nonmetacharacters literally (IEEE 1800.2-2020 Section F.3.3.1)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_is_match_simplified_nonmetacharacters_are_literal.expected
*/
// Simplified notation only; no slash-delimited POSIX expression or DPI.
module test_is_match_simplified_nonmetacharacters_are_literal;
  import uvm_pkg::*;
  initial begin

    $display("UT: literal dot %0d changed %0d", uvm_is_match("node.leaf", "node.leaf"),
    uvm_is_match("node.leaf", "nodeXleaf"));
    $display("UT: literal brackets %0d expanded %0d", uvm_is_match("node[ab]", "node[ab]"),
    uvm_is_match("node[ab]", "nodea"));
    $display("UT: literal parentheses %0d omitted %0d", uvm_is_match("node(x)", "node(x)"),
    uvm_is_match("node(x)", "nodex"));
    $finish;
  end
endmodule
