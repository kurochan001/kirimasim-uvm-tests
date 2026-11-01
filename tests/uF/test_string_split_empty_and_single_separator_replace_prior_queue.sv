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
