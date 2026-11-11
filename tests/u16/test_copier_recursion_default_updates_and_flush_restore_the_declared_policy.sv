/*
:name: test_copier_recursion_default_updates_and_flush_restore_the_declared_policy
:description: copier recursion default updates and flush restore the declared policy
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.3 16.1.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_recursion_default_updates_and_flush_restore_the_declared_policy.expected
*/
// What it checks:
// 1. A fresh copier recursion getter returns UVM_DEFAULT_POLICY.
// 2. A selected copier stores SHALLOW independently of a peer.
// 3. Flush restores the declared copier recursion default.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.6.3 (UVM-POLICY-AUDIT-COPIER-RECURSION-INITIAL) gives rule
//    1 above. Setup: Use the selected original fixtures, explicit arguments
//    and stage observations in the linked anchors; each fresh policy and peer
//    is independently constructed. Expected: A fresh copier recursion getter
//    returns UVM_DEFAULT_POLICY.
// 2. 1800.2-2020 16.6.3 (UVM-POLICY-AUDIT-COPIER-RECURSION-UPDATE) gives rule
//    2 above. Setup: Use the selected original fixtures, explicit arguments
//    and stage observations in the linked anchors; each fresh policy and peer
//    is independently constructed. Expected: A selected copier stores SHALLOW
//    independently of a peer.
// 3. 1800.2-2020 16.6.3 (UVM-POLICY-AUDIT-COPIER-RECURSION-FLUSH) gives rule 3
//    above. Setup: Use the selected original fixtures, explicit arguments and
//    stage observations in the linked anchors; each fresh policy and peer is
//    independently constructed. Expected: Flush restores the declared copier
//    recursion default.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_copier_recursion_default_updates_and_flush_restore_the_declared_policy;
  import uvm_pkg::*;
  initial begin
    automatic uvm_copier selected=new();
    automatic uvm_copier peer=new();
    $display("UT: copy_policy_default %0d",selected.get_recursion_policy()==UVM_DEFAULT_POLICY);
    selected.set_recursion_policy(UVM_SHALLOW);
    $display("UT: copy_policy_changed selected %0d peer %0d",
             selected.get_recursion_policy()==UVM_SHALLOW,
             peer.get_recursion_policy()==UVM_DEFAULT_POLICY);
    selected.flush();
    $display("UT: copy_policy_flushed %0d",selected.get_recursion_policy()==UVM_DEFAULT_POLICY);
    $finish;
  end
endmodule
