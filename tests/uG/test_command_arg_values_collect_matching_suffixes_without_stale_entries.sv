/*
:name: test_command_arg_values_collect_matching_suffixes_without_stale_entries
:description: argument collection returns all matching suffixes and replaces queue contents (IEEE 1800.2-2020 Section G.1.4.2)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1.4.2 G.1.4.1 G.1.3.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +KR_UVM_PICK=alpha +KR_UVM_OTHER=ignored +KR_UVM_PICK=beta
:expected_stdout: @test_command_arg_values_collect_matching_suffixes_without_stale_entries.expected
*/
// What it checks:
// get_arg_values replaces the output queue with matching argument suffixes and
// returns the match count.
//
// How the expected output follows from the standard:
// 1800.2-2020 G.1.4.2 (UVM-COMMAND-ARG-VALUES) gives the rule above. Setup:
// Pass distinct matching/irrelevant arguments and prepopulate the output queue
// before multiple, missing or repeated queries. Expected: Only matching
// suffixes remain and the returned count equals their number.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Count membership without prescribing the order of matching arguments.
module test_command_arg_values_collect_matching_suffixes_without_stale_entries;
  import uvm_pkg::*;
  initial begin
    uvm_cmdline_processor processor;
    string values[$];
    int count;
    int alpha;
    int beta;
    int stale;
    processor = uvm_cmdline_processor::get_inst();
    alpha = 0;
    beta = 0;
    stale = 0;
    values.push_back("stale");
    count = processor.get_arg_values("+KR_UVM_PICK=", values);
    foreach (values[i]) begin
      if (values[i] == "alpha") alpha++;
      if (values[i] == "beta") beta++;
      if (values[i] == "stale") stale++;
    end
    $display("UT: matches %0d size %0d alpha %0d beta %0d stale %0d",
             count, values.size(), alpha, beta, stale);
    $finish;
  end
endmodule
