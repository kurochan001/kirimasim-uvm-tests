/*
:name: test_phase_callbacks_observe_their_phase_states
:description: phase callbacks observe STARTED READY_TO_END and ENDED states (IEEE 1800.2-2020 Section 9.3.1.4.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.4.1 13.1.4.3.1 13.1.4.3.2 13.1.4.3.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_phase_callbacks_observe_their_phase_states.expected
*/
// Capture states only for main. A positive objection interval ensures
// the task is executing before its ready and ended callbacks are inspected.

module test_phase_callbacks_observe_their_phase_states;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    bit started_state = 0;
    bit executing_state = 0;
    bit ready_state = 0;
    bit ended_state = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void phase_started(uvm_phase phase);
      super.phase_started(phase);
      if (phase.get_name() == "main") started_state = phase.get_state() == UVM_PHASE_STARTED;
    endfunction
    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      #2;
      executing_state = phase.get_state() == UVM_PHASE_EXECUTING;
      phase.drop_objection(this);
    endtask
    function void phase_ready_to_end(uvm_phase phase);
      super.phase_ready_to_end(phase);
      if (phase.get_name() == "main") ready_state = phase.get_state() == UVM_PHASE_READY_TO_END;
    endfunction
    function void phase_ended(uvm_phase phase);
      super.phase_ended(phase);
      if (phase.get_name() == "main") ended_state = phase.get_state() == UVM_PHASE_ENDED;
    endfunction
    function void extract_phase(uvm_phase phase);
      $display("UT: states started %0d executing %0d ready %0d ended %0d",
               started_state, executing_state, ready_state, ended_state);
    endfunction
  endclass
  initial run_test();

  initial begin
    #20;
    $fatal(1, "test watchdog expired");
  end
endmodule
