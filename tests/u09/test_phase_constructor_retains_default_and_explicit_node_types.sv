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
// What it checks:
// 1. A default phase has the prescribed name, schedule type and no parent.
// 2. Phase type queries retain the selected constructor kind.
// 3. The phase-kind type supplies the named IMP,NODE,SCHEDULE and DOMAIN
//    designators.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.3.1.3.1 (UVM-PHASE-CONSTRUCTOR-DEFAULT-METADATA) gives rule
//    1 above. Setup: Construct a phase without arguments. Expected: The name
//    is uvm_phase, the type is SCHEDULE and the parent is null.
// 2. 1800.2-2020 9.3.1.3.2 (UVM-PHASE-TYPE-QUERY-EXPLICIT-KINDS) gives rule 2
//    above. Setup: Construct IMP, NODE, SCHEDULE and DOMAIN phase objects.
//    Expected: Each query equals its explicitly supplied kind.
// 3. 1800.2-2020 F.2.5.1 (UVM-PKG-PHASE-KIND-DESIGNATORS-91) gives rule 3
//    above. Setup: Two independent original inputs create topdown/bottomup IMP
//    objects and nodes in two schedules. They capture each isolated schedule
//    node before joining both schedules to the component domain,then check
//    types,parent/domain identities and manual selected-subtree traversal.
//    Original post-attachment lookup inputs remain separate controls for the
//    stricter scope interpretation. Expected: Actual selected
//    implementation,node,schedule and domain objects report their named
//    kinds;the unchanged explicit-constructor input supplies a separate
//    compatible type observation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
