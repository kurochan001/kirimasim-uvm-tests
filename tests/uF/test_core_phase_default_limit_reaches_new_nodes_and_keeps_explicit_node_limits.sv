/*
:name: test_core_phase_default_limit_reaches_new_nodes_and_keeps_explicit_node_limits
:description: The core phase limit reaches phase defaults and newly constructed nodes
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.10 F.4.1.4.11 9.3.1.3.3 9.3.1.3.4 9.3.1.3.5 9.3.1.3.6 1800-2023 6.21 8.20 8.21 13.5.2 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_core_phase_default_limit_reaches_new_nodes_and_keeps_explicit_node_limits.expected
*/
// What it checks:
// 1. The initial global ready-to-end maximum is twenty.
// 2. The core setter changes the global default used by phases.
// 3. The core getter returns the selected global ready-to-end default.
// 4. An explicit per-node maximum remains independent of subsequent global
//    default changes.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.3.1.3.5 (UVM-CORE-DECL-AUDIT-LIMIT-INITIAL-DEFAULT) gives
//    rule 1 above. Setup: Set the core default before new node construction or
//    run_test. Keep explicit node limits separate. The live probe raises on
//    every main readiness callback and drops after one nanosecond. Expected:
//    The selected core and phase default accessors initially both return
//    twenty.
// 2. 1800.2-2020 F.4.1.4.10 (UVM-CORE-DECL-AUDIT-LIMIT-CORE-SET) gives rule 2
//    above. Setup: Set the core default before new node construction or
//    run_test. Keep explicit node limits separate. The live probe raises on
//    every main readiness callback and drops after one nanosecond. Expected:
//    The core and phase defaults agree at seven and then nine; a new
//    unmodified node inherits seven.
// 3. 1800.2-2020 F.4.1.4.11 (UVM-CORE-DECL-AUDIT-LIMIT-CORE-GET) gives rule 3
//    above. Setup: Set the core default before new node construction or
//    run_test. Keep explicit node limits separate. The live probe raises on
//    every main readiness callback and drops after one nanosecond. Expected:
//    The getter initially returns twenty, then seven, and retains the saved
//    value after restoration.
// 4. 1800.2-2020 9.3.1.3.3 (UVM-CORE-DECL-AUDIT-LIMIT-EXPLICIT-INSTANCE) gives
//    rule 4 above. Setup: Set the core default before new node construction or
//    run_test. Keep explicit node limits separate. The live probe raises on
//    every main readiness callback and drops after one nanosecond. Expected:
//    The first node retains three while a new peer inherits seven and the
//    global default becomes nine.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_core_phase_default_limit_reaches_new_nodes_and_keeps_explicit_node_limits;
  import uvm_pkg::*;
  initial begin
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    uvm_phase first, second;
    int saved;
    saved=service.get_phase_max_ready_to_end();
    $display("UT: core_limit initial %0d phase_default %0d",saved,
      uvm_phase::get_default_max_ready_to_end_iterations());
    service.set_phase_max_ready_to_end(7);
    first=new("first64",UVM_PHASE_NODE);
    first.set_max_ready_to_end_iterations(3);
    second=new("second64",UVM_PHASE_NODE);
    $display("UT: core_limit selected %0d phase_default %0d explicit %0d inherited %0d",
      service.get_phase_max_ready_to_end(),
      uvm_phase::get_default_max_ready_to_end_iterations(),
      first.get_max_ready_to_end_iterations(),second.get_max_ready_to_end_iterations());
    service.set_phase_max_ready_to_end(9);
    $display("UT: core_limit changed %0d explicit_retained %0d",
      uvm_phase::get_default_max_ready_to_end_iterations(),
      first.get_max_ready_to_end_iterations()==3);
    service.set_phase_max_ready_to_end(saved);
    $display("UT: core_limit restored %0d",service.get_phase_max_ready_to_end()==saved);
    $finish;
  end
endmodule
