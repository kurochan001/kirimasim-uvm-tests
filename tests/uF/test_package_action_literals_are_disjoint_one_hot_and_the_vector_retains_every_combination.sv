/*
:name: test_package_action_literals_are_disjoint_one_hot_and_the_vector_retains_every_combination
:description: Report action values are one-hot and uvm_action preserves all 64 selected subsets
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.2.2 F.2.2.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_action_literals_are_disjoint_one_hot_and_the_vector_retains_every_combination.expected
*/
// What it checks:
// 1. The six nonzero report-action literals are mutually disjoint one-hot
//    values; NO_ACTION is zero.
// 2. uvm_action retains arbitrary OR combinations of the specified action
//    literals.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.2.2.2 (UVM-PACKAGE-AUDIT-ACTION-ONE-HOT) gives rule 1
//    above. Setup: DISPLAY, LOG, COUNT, EXIT, STOP and RM_RECORD are combined
//    without executing termination/interactive actions. Expected: Every
//    nonzero literal has one set bit, all distinct pairs have no common bit
//    and NO_ACTION equals zero.
// 2. 1800.2-2020 F.2.2.3 (UVM-PACKAGE-AUDIT-ACTION-CAPACITY) gives rule 2
//    above. Setup: DISPLAY, LOG, COUNT, EXIT, STOP and RM_RECORD are combined
//    without executing termination/interactive actions. Expected: For all 64
//    subsets, every selected action bit is present and every unselected action
//    bit is absent after storage.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_package_action_literals_are_disjoint_one_hot_and_the_vector_retains_every_combination;
  import uvm_pkg::*;
  initial begin
    automatic uvm_action_type flags[6]='{UVM_DISPLAY,UVM_LOG,UVM_COUNT,
      UVM_EXIT,UVM_STOP,UVM_RM_RECORD};
    automatic bit one_hot=1,disjoint=1,combinations=1;
    uvm_action combined;
    foreach (flags[i]) begin
      one_hot &= $countones(flags[i])==1;
      foreach (flags[j]) if (i!=j) disjoint &= (flags[i] & flags[j])==0;
    end
    for (int mask=0;mask<64;mask++) begin
      combined=UVM_NO_ACTION;
      foreach (flags[i]) if ((mask >> i)&1) combined |= flags[i];
      foreach (flags[i]) combinations &= ((combined & flags[i])!=0)==(((mask >> i)&1)!=0);
    end
    $display("UT: actions zero %0d one_hot %0d disjoint %0d all_combinations %0d",
      UVM_NO_ACTION==0,one_hot,disjoint,combinations);
    $finish;
  end
endmodule
