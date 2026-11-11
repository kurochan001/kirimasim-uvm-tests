/*
:name: test_string_split_empty_and_single_separator_replace_prior_queue
:description: empty strings and one separator yield their specified empty fields (IEEE 1800.2-2020 Section F.3.3.2)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.3.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_string_split_empty_and_single_separator_replace_prior_queue.expected
*/
// What it checks:
// String splitting preserves empty fields created by adjacent or edge
// separators.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.3.3.2 (UVM-STRING-SPLIT-EMPTY-FIELDS) gives the rule above.
// Setup: Inputs include adjacent separators, leading/trailing separators and
// an empty string. Expected: Result size is separator count plus one; empty
// input yields one empty field.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Both calls replace prior contents. Guard indexes to avoid making an
// invalid implementation's queue length cause an unrelated out-of-bounds read.
module test_string_split_empty_and_single_separator_replace_prior_queue;
  import uvm_pkg::*;
  initial begin
    string values[$];
    values.push_back("stale");
    uvm_string_split("", ":", values);
    $display("UT: empty_count %0d", values.size());
    if (values.size() == 1) $display("UT: empty_value %0d", values[0] == "");
    uvm_string_split(":", ":", values);
    $display("UT: separator_count %0d", values.size());
    if (values.size() == 2)
      $display("UT: separator_values %0d %0d", values[0] == "", values[1] == "");
    $finish;
  end
endmodule
