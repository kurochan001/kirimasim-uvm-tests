/*
:name: test_phase_ready_iteration_cap_2_bounds_repeated_raise_drop_callbacks
:description: ready-to-end cap bounds callbacks that repeatedly raise and drain objections (IEEE 1800.2-2020 Section 13.1.4.3.2)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4.3.2 13.1.4.3.3 9.3.1.3.3 9.3.1.3.4 9.8.1.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_ready_iteration_cap_2_bounds_repeated_raise_drop_callbacks.expected
*/
// What it checks:
// The ready-to-end iteration cap forces progress to phase_ended despite
// repeated new objections.
//
// How the expected output follows from the standard:
// 1800.2-2020 13.1.4.3.2 (UVM-PHASE-READY-ITERATION-CAP) gives the rule above.
// Setup: Raise and later drop an objection from every ready callback through
// the configured maximum. Expected: The capped iteration reaches phase_ended
// without unbounded callback retries.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Every ready callback raises and schedules a delayed drop. Without the
// cap this would repeat forever. Count callbacks and observe phase_ended.
module test_phase_ready_iteration_cap_2_bounds_repeated_raise_drop_callbacks;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    int ready_calls = 0;
    int ended_calls = 0;
    uvm_phase watched;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task main_phase(uvm_phase phase);
      watched = phase;
      phase.set_max_ready_to_end_iterations(2);
      phase.raise_objection(this);
      #1;
      phase.drop_objection(this);
    endtask
    virtual function void phase_ready_to_end(uvm_phase phase);
      if (phase.get_name() == "main") begin
        ready_calls++;
        phase.raise_objection(this);
        fork begin #1; watched.drop_objection(this); end join_none
      end
    endfunction
    virtual function void phase_ended(uvm_phase phase);
      if (phase.get_name() == "main") begin
        ended_calls++;
      end
    endfunction
    virtual function void extract_phase(uvm_phase phase);
      $display("UT: ready_calls %0d ended_calls %0d", ready_calls, ended_calls);
    endfunction
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "ready-cap watchdog expired"); end
endmodule
