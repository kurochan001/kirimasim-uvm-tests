/*
:name: test_phase_iteration_limits_have_instance_and_default_state
:description: new phases inherit the global ready iteration limit and keep independent explicit limits (IEEE 1800.2-2020 Section 9.3.1.3.3)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.3.3 9.3.1.3.4 9.3.1.3.5 9.3.1.3.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_iteration_limits_have_instance_and_default_state.expected
*/
// What it checks:
// 1. The global default ready-to-end iteration limit starts at 20 and is
//    configurable.
// 2. Each phase node stores its own configured ready-to-end iteration limit.
// 3. The instance getter returns its current ready-to-end limit.
// 4. Under the heading/prose interpretation, the default getter reports the
//    class default.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.3.1.3.5 (UVM-PHASE-READY-DEFAULT-LIMIT) gives rule 1 above.
//    Setup: Read the class default, change it before node construction and
//    restore it afterwards. Expected: The initial value is 20, new nodes
//    inherit the configured value 7 and restoration succeeds.
// 2. 1800.2-2020 9.3.1.3.3 (UVM-PHASE-READY-NODE-LIMIT) gives rule 2 above.
//    Setup: Construct two nodes from one default and assign different local
//    limits. Expected: Node getters return 3 and 5 without changing the global
//    default or each other.
// 3. 1800.2-2020 9.3.1.3.4 (UVM-PHASE-CONTRACT-ITERATION-INSTANCE-GETTER)
//    gives rule 3 above. Setup: An unchanged two-instance fixture changes,
//    queries and restores the class default. Expected: Inherited limits are
//    7/7 and explicit independent limits are 3/5.
// 4. 1800.2-2020 9.3.1.3.6 (UVM-PHASE-CONTRACT-ITERATION-DEFAULT-GETTER) gives
//    rule 4 above. Setup: An unchanged two-instance fixture changes, queries
//    and restores the class default. Expected: The initial default is 20 and
//    the restored-default comparison is true.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Change the default before constructing two phase nodes. Updating each
// node explicitly leaves the other node unchanged, then restore the default.
// Read the class default after static initialization, in an executable
// statement rather than a declaration initializer.

module test_phase_iteration_limits_have_instance_and_default_state;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    int saved;
    uvm_phase first;
    uvm_phase second;
    saved = uvm_phase::get_default_max_ready_to_end_iterations();
    $display("UT: initial default %0d", saved);
    uvm_phase::set_default_max_ready_to_end_iterations(7);
    first = new("first", UVM_PHASE_NODE);
    second = new("second", UVM_PHASE_NODE);
    $display("UT: inherited %0d %0d", first.get_max_ready_to_end_iterations(),
        second.get_max_ready_to_end_iterations());
    first.set_max_ready_to_end_iterations(3);
    second.set_max_ready_to_end_iterations(5);
    $display("UT: independent %0d %0d", first.get_max_ready_to_end_iterations(),
        second.get_max_ready_to_end_iterations());
    uvm_phase::set_default_max_ready_to_end_iterations(saved);
    $display("UT: restored default %0d",
        uvm_phase::get_default_max_ready_to_end_iterations() == saved);
    $finish;
  end
endmodule
