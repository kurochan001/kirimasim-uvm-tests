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
