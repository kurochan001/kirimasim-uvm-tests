/*
:name: test_phase_ready_to_end_objection_extends_main
:description: raising an objection in phase_ready_to_end delays completion and causes another iteration (IEEE 1800.2-2020 Section 9.6)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.6 13.1.4.3.2 9.3.1.3.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_phase_ready_to_end_objection_extends_main.expected
*/
// What it checks:
// An objection raised from ready_to_end defers ending and permits a later
// ready-to-end iteration.
//
// How the expected output follows from the standard:
// 1800.2-2020 13.1.4.3.2 (UVM-PHASE-READY-REOBJECTION) gives the rule above.
// Setup: The first main ready callback raises, then drops after a positive
// delay. Expected: A second ready callback occurs after the delay and the
// phase elapsed time is 3.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The first ready callback raises an objection and forks a delayed drop.
// A second ready iteration occurs after that objection has been dropped.

module test_phase_ready_to_end_objection_extends_main;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    int ready_calls = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      #1;
      phase.drop_objection(this);
    endtask
    function void phase_ready_to_end(uvm_phase phase);
      super.phase_ready_to_end(phase);
      if (phase.get_name() == "main") begin
        ready_calls++;
        if (ready_calls == 1) begin
          phase.raise_objection(this);
          fork
            begin
              #2;
              phase.drop_objection(this);
            end
          join_none
        end
      end
    endfunction
    function void extract_phase(uvm_phase phase);
      $display("UT: ready calls %0d elapsed %0d", ready_calls, $time);
    endfunction
  endclass
  initial run_test();

  initial begin
    #20;
    $fatal(1, "test watchdog expired");
  end
endmodule
