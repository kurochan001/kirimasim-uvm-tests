/*
:name: test_command_vpi_extended_regex_matches_grouped_alternatives_and_clears_queries
:description: command vpi extended regex matches grouped alternatives and clears queries (IEEE 1800.2-2020 Section G.1.3.4)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1.3.4 G.1.2 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_cmdline_backend: vpi
:uvm_cmdline_oracle: verilator@5.052
:uvm_defines: UVM_HDL_NO_DPI
:dpi_c: @../../tools/cmdline_backend/uvm_cmdline_vpi.cpp
:files: ../../tools/cmdline_backend/uvm_cmdline_regex.cpp ../../tools/cmdline_backend/malloc.h
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +kr_rx=red +kr_rx=blue +kr_rx=green +other_kr_rx=red
:expected_stdout: @test_command_vpi_extended_regex_matches_grouped_alternatives_and_clears_queries.expected
*/
// What it checks:
// 1. Slash-delimited match expressions support selected extended-regex
//    alternation and anchors.
// 2. Successive regex queries replace old matches and clear on no match.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 G.1.3.4 (UVM-CMDLINE-REGEX-ALTERNATION-AND-ANCHORS) gives
//    rule 1 above. Setup: The anchored pattern selects red or blue and
//    excludes green and a different leading prefix. Expected: Only red and
//    blue are returned, with count two and no stale entry.
// 2. 1800.2-2020 G.1.3.4 (UVM-CMDLINE-REGEX-QUEUE-REPLACEMENT) gives rule 2
//    above. Setup: A two-result query is followed by one green match and a
//    missing expression. Expected: The fresh queue contains only green, then
//    becomes empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independent expected membership follows anchored extended regex syntax.
// Only selected alternation/anchor cases are checked, not malformed
// expressions
// or regex suffix extraction.
module test_command_vpi_extended_regex_matches_grouped_alternatives_and_clears_queries;
  import uvm_pkg::*;
  initial begin
    automatic uvm_cmdline_processor processor = uvm_cmdline_processor::get_inst();
    string args[$];
    int count, red, blue, stale;
    args.push_back("stale");
    count = processor.get_arg_matches("/^\\+kr_rx=(red|blue)$/", args);
    red = 0; blue = 0; stale = 0;
    foreach (args[i]) begin
      if (args[i] == "+kr_rx=red") red++;
      if (args[i] == "+kr_rx=blue") blue++;
      if (args[i] == "stale") stale++;
    end
    $display("UT: regex count %0d size %0d red %0d blue %0d stale %0d", count,
             args.size(), red, blue, stale);
    count = processor.get_arg_matches("/^\\+kr_rx=green$/", args);
    $display("UT: replaced count %0d size %0d green %0d", count, args.size(),
             args.size() == 1 && args[0] == "+kr_rx=green");
    count = processor.get_arg_matches("/^\\+kr_absent=/", args);
    $display("UT: missing count %0d size %0d", count, args.size());
    $finish;
  end
endmodule
