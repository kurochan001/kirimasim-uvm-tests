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
