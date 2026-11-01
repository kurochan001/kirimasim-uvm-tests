/*
:name: test_string_split_preserves_consecutive_and_edge_empty_fields
:description: string splitting retains empty entries around consecutive and edge separators (IEEE 1800.2-2020 Section F.3.3.2)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.3.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_string_split_preserves_consecutive_and_edge_empty_fields.expected
*/
// Inspect positions only after checking the queue size. No whitespace or
// regular-expression interpretation is needed for the single-byte delimiter.
module test_string_split_preserves_consecutive_and_edge_empty_fields;
  import uvm_pkg::*;
  initial begin
    string values[$];
    values.push_back("stale");
    uvm_string_split(",red,,blue,", ",", values);
    $display("UT: count %0d", values.size());
    if (values.size() == 5)
      $display("UT: positions %0d %0d %0d %0d %0d", values[0] == "",
               values[1] == "red", values[2] == "", values[3] == "blue", values[4] == "");
    $finish;
  end
endmodule
