/*
:name: test_task_phase_return_does_not_end_held_phase
:description: a returned child task does not end a phase held by another objection (IEEE 1800.2-2020 Section 9.6)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.6 9.8.2.8 10.5.1.3.3 13.1.4.2.8
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_task_phase_return_does_not_end_held_phase.expected
*/
// The child returns immediately. The test holds a main-phase objection
// and observes the return after time advances before dropping its objection.

module test_task_phase_return_does_not_end_held_phase;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class worker extends uvm_component;
    `uvm_component_utils(worker)
    bit returned = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task main_phase(uvm_phase phase);
      returned = 1;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    worker child;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      child = worker::type_id::create("child", this);
    endfunction
    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      #3;
      $display("UT: child returned %0d elapsed %0d", child.returned, $time);
      phase.drop_objection(this);
    endtask
    function void extract_phase(uvm_phase phase);
      super.extract_phase(phase);
      $display("UT: extract elapsed %0d", $time);
    endfunction
  endclass
  initial run_test();
endmodule
