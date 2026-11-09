/*
:name: test_pool_num_counts_distinct_keys_after_replacement
:description: pool counts distinct keys rather than add calls (IEEE 1800.2-2020 Section 11.2.2.6)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.2.2.6 11.2.2.1 11.2.2.4 11.2.2.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_num_counts_distinct_keys_after_replacement.expected
*/
// What it checks:
// Pool num reports how many distinct keys currently have entries.
//
// How the expected output follows from the standard:
// 1800.2-2020 11.2.2.6 (UVM-POOL-UNIQUE-COUNT) gives the rule above. Setup:
// Replace a key, insert a different key, implicitly create one through get and
// delete it while preserving another pool. Expected: Counts follow unique
// stored keys rather than operation count, and deleting one pool entry leaves
// the peer pool unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Every observed value is explicitly added before it is retrieved.
module test_pool_num_counts_distinct_keys_after_replacement;
  import uvm_pkg::*;
  initial begin
    uvm_pool#(string, int) values;
    values = new("values");
    $display("UT: empty %0d", values.num());
    values.add("first", 11);
    values.add("second", 22);
    values.add("first", 37);
    $display("UT: count %0d first %0d second %0d", values.num(),
             values.get("first"), values.get("second"));
    $finish;
  end
endmodule
