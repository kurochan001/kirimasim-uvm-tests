/*
:name: test_phase_constructor_retains_default_and_explicit_node_types
:description: phase constructors retain default and explicit node types (IEEE 1800.2-2020 Section 9.3.1.3.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.3.1 9.3.1.3.2 5.3.4.2 F.2.5.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_constructor_retains_default_and_explicit_node_types.expected
*/
// Inspect local phase metadata and graphs without executing phase callbacks.
// Do not interpret get_schedule return typing or the get_imp NODE/IMP wording.
module test_phase_constructor_retains_default_and_explicit_node_types;
  import uvm_pkg::*;

  initial begin
    automatic uvm_phase defaults = new();
    automatic uvm_phase implementation = new("implementation", UVM_PHASE_IMP);
    automatic uvm_phase node = new("node", UVM_PHASE_NODE);
    automatic uvm_phase schedule = new("schedule", UVM_PHASE_SCHEDULE);
    automatic uvm_phase domain = new("domain", UVM_PHASE_DOMAIN);
    $display("UT: defaults name %0d schedule %0d root %0d", defaults.get_name() == "uvm_phase",
    defaults.get_phase_type() == UVM_PHASE_SCHEDULE, defaults.get_parent() == null);
    $display("UT: explicit imp %0d node %0d schedule %0d domain %0d",
    implementation.get_phase_type() == UVM_PHASE_IMP, node.get_phase_type() == UVM_PHASE_NODE,
    schedule.get_phase_type() == UVM_PHASE_SCHEDULE, domain.get_phase_type() == UVM_PHASE_DOMAIN);
    $finish;
  end

endmodule
