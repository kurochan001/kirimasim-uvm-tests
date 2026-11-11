/*
:name: test_comparer_threshold_default_updates_and_flush_restore_the_declared_boundary
:description: comparer threshold default updates and flush restore the declared boundary
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.6 16.3.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_threshold_default_updates_and_flush_restore_the_declared_boundary.expected
*/
// What it checks:
// 1. A fresh comparer threshold is one.
// 2. The comparer threshold accepts zero and five independently of a fresh
//    peer.
// 3. Flush restores the declared comparer threshold of one.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.3.6 (UVM-POLICY-AUDIT-COMPARER-THRESHOLD-INITIAL) gives
//    rule 1 above. Setup: Use the selected original fixtures, explicit
//    arguments and stage observations in the linked anchors; each fresh policy
//    and peer is independently constructed. Expected: A fresh comparer
//    threshold is one.
// 2. 1800.2-2020 16.3.6 (UVM-POLICY-AUDIT-COMPARER-THRESHOLD-UPDATE) gives
//    rule 2 above. Setup: Use the selected original fixtures, explicit
//    arguments and stage observations in the linked anchors; each fresh policy
//    and peer is independently constructed. Expected: The comparer threshold
//    accepts zero and five independently of a fresh peer.
// 3. 1800.2-2020 16.3.6 (UVM-POLICY-AUDIT-COMPARER-THRESHOLD-FLUSH) gives rule
//    3 above. Setup: Use the selected original fixtures, explicit arguments
//    and stage observations in the linked anchors; each fresh policy and peer
//    is independently constructed. Expected: Flush restores the declared
//    comparer threshold of one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_comparer_threshold_default_updates_and_flush_restore_the_declared_boundary;
  import uvm_pkg::*;
  initial begin
    automatic uvm_comparer selected=new();
    automatic uvm_comparer peer=new();
    $display("UT: threshold_default %0d",selected.get_threshold()==1);
    selected.set_threshold(0);
    $display("UT: threshold_zero selected %0d peer %0d",selected.get_threshold()==0,
             peer.get_threshold()==1);
    selected.set_threshold(5);
    $display("UT: threshold_five selected %0d peer %0d",selected.get_threshold()==5,
             peer.get_threshold()==1);
    selected.flush();
    $display("UT: threshold_flushed %0d",selected.get_threshold()==1);
    $finish;
  end
endmodule
