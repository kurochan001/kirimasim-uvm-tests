/*
:name: test_command_arg_values_clear_on_no_match_and_repeat_without_appending
:description: argument queries clear unmatched queues and replace repeated results (IEEE 1800.2-2020 Section G.1.4.2)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.1.4.2 G.1.4.1 G.1.3.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +KR_UVM_ONE=leaf +KR_UVM_UNRELATED=present
:expected_stdout: @test_command_arg_values_clear_on_no_match_and_repeat_without_appending.expected
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
// Query the same singleton twice and a missing prefix once. Each result
// stands on its own, independent of the queue's previous contents.
module test_command_arg_values_clear_on_no_match_and_repeat_without_appending;
  import uvm_pkg::*;
  initial begin
    uvm_cmdline_processor processor;
    string values[$];
    int count;
    processor = uvm_cmdline_processor::get_inst();
    values.push_back("stale");
    count = processor.get_arg_values("+KR_UVM_ABSENT=", values);
    $display("UT: missing count %0d size %0d", count, values.size());
    count = processor.get_arg_values("+KR_UVM_ONE=", values);
    $display("UT: first count %0d size %0d", count, values.size());
    if (values.size() == 1) $display("UT: first_value %0d", values[0] == "leaf");
    values.push_back("stale_again");
    count = processor.get_arg_values("+KR_UVM_ONE=", values);
    $display("UT: repeated count %0d size %0d", count, values.size());
    if (values.size() == 1) $display("UT: repeated_value %0d", values[0] == "leaf");
    $finish;
  end
endmodule
