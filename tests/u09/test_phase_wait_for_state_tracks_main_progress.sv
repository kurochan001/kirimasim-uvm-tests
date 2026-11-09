/*
:name: test_phase_wait_for_state_tracks_main_progress
:description: wait_for_state resumes for executing and ended main phase states (IEEE 1800.2-2020 Section 9.3.1.8.3)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.8.3 9.3.1.4.1 9.3.1.4.3 9.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_phase_wait_for_state_tracks_main_progress.expected
*/
// What it checks:
// wait_for_state blocks until the phase state satisfies its selected
// comparison.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.3.1.8.3 (UVM-PHASE-WAIT-STATE) gives the rule above. Setup: An
// external observer waits for executing and then ended while a run objection
// keeps it alive. Expected: Executing is seen at elapsed zero and ended is
// reached after the two-unit active interval.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An external observer waits on the main phase node. A run objection
// keeps the test alive until the observer has recorded both state transitions.

module test_phase_wait_for_state_tracks_main_progress;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  uvm_phase main_node = null;
  bit observed_end = 0;
  class t extends uvm_test;
    `uvm_component_utils(t)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      main_node = phase.find_by_name("main", 0);
      if (main_node == null) $fatal(1, "main phase node not found");
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      wait (observed_end);
      phase.drop_objection(this);
    endtask
    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      #2;
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test();
  initial begin
    wait (main_node != null);
    main_node.wait_for_state(UVM_PHASE_EXECUTING, UVM_GTE);
    $display("UT: executing state %0d elapsed %0d", main_node.get_state()
        == UVM_PHASE_EXECUTING, $time);
    main_node.wait_for_state(UVM_PHASE_ENDED, UVM_GTE);
    $display("UT: ended reached %0d elapsed %0d", main_node.get_state() >= UVM_PHASE_ENDED, $time);
    observed_end = 1;
  end

  initial begin
    #20;
    $fatal(1, "test watchdog expired");
  end
endmodule
