/*
:name: test_regex_cmdline_get_arg_matches_119
:description: get_arg_matches applies a slash-delimited extended regular expression to each argument and otherwise matches an argument prefix (IEEE 1800.2-2020 Section G.1.3.4)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1.3.4 G.1.2 G.1.3.1 1800-2023 6.21
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
:args: +mode119=fast +mode119=slow +mode119x
:expected_stdout: @test_regex_cmdline_get_arg_matches_119.expected
*/
// What it checks:
// get_arg_matches applies a slash-delimited extended regular expression to
// each argument and otherwise matches a prefix.
//
// How the expected output follows from the standard:
// 1800.2-2020 G.1.3.4 (UVM-REGEX-CMDLINE-ARG-MATCHES) gives the rule above.
// Setup: The process receives +mode119=fast, +mode119=slow and +mode119x;
// match an anchored alternation, the plain prefix +mode119 and an absent
// value. Expected: The alternation returns the first two, the prefix all
// three, and the absent value none.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The process receives +mode119=fast, +mode119=slow and +mode119x. An anchored
// regular expression with an alternation must select the first two, the plain
// prefix must select all three, and a regular expression for an absent value
// must select none. The pinned regex DPI and the original command-line VPI
// bridge are enabled; the ordinary UVM_NO_DPI condition cannot evaluate regular
// expressions, so this case runs only in the command-line condition. Only the
// lines that begin with "UT: " are compared.
module test_regex_cmdline_get_arg_matches_119;
  import uvm_pkg::*;

  initial begin
    automatic uvm_cmdline_processor processor = uvm_cmdline_processor::get_inst();
    string matched[$];
    int regex_count, prefix_count, none_count, fast, slow;
    regex_count = processor.get_arg_matches("/^\\+mode119=(fast|slow)$/", matched);
    fast = 0; slow = 0;
    foreach (matched[i]) begin
      if (matched[i] == "+mode119=fast") fast++;
      if (matched[i] == "+mode119=slow") slow++;
    end
    prefix_count = processor.get_arg_matches("+mode119", matched);
    none_count = processor.get_arg_matches("/^\\+mode119=medium$/", matched);
    $display("UT: regex count %0d fast %0d slow %0d", regex_count, fast, slow);
    $display("UT: prefix count %0d none count %0d", prefix_count, none_count);
    $finish;
  end
endmodule
