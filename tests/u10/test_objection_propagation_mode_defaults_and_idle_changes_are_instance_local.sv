/*
:name: test_objection_propagation_mode_defaults_and_idle_changes_are_instance_local
:description: objection propagation mode defaults and idle changes are instance local (IEEE 1800.2-2020 Section 10.5.1.3.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.1 10.5.1.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_propagation_mode_defaults_and_idle_changes_are_instance_local.expected
*/
// What it checks:
// 1. The propagation getter returns one before any setter call.
// 2. The getter reflects the latest legal propagation mode independently per
//    objection.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.5.1.3.1 (UVM-OBJECTION-CB-REVIEW-PROPAGATION-DEFAULT)
//    gives rule 1 above. Setup: Construct two independent objections and query
//    both before changes. Expected: Both modes are one.
// 2. 1800.2-2020 10.5.1.3.1 (UVM-OBJECTION-CB-REVIEW-IDLE-MODE-QUERY) gives
//    rule 2 above. Setup: Disable then restore one idle objection while
//    leaving a peer untouched. Expected: The selected mode changes zero then
//    one; the peer remains one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// No objections are raised or draining. The standard explicitly defines the
// initial getter value and permits idle changes; active-mode changes are
// tested
// separately with real objection/drain state.
module test_objection_propagation_mode_defaults_and_idle_changes_are_instance_local;
  import uvm_pkg::*;
  initial begin
    automatic uvm_objection subject = new("subject");
    automatic uvm_objection peer = new("peer");
    $display("UT: propagate_default subject %0d peer %0d",
             subject.get_propagate_mode(),peer.get_propagate_mode());
    subject.set_propagate_mode(0);
    $display("UT: propagate_idle_disabled subject %0d peer %0d",
             subject.get_propagate_mode(),peer.get_propagate_mode());
    subject.set_propagate_mode(1);
    $display("UT: propagate_idle_restored subject %0d peer %0d",
             subject.get_propagate_mode(),peer.get_propagate_mode());
    $finish;
  end
endmodule
