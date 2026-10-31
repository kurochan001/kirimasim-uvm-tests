/*
:name: test_task_phase_kills_remaining_child_task
:description: ending a task phase kills a child task that has not returned (IEEE 1800.2-2020 Section 9.6)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.6 9.8.2.1 9.8.2.8 13.1.4.2.1 13.1.4.2.8
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_task_phase_kills_remaining_child_task.expected
*/
// The child starts during a held pre-reset phase, then waits beyond its
// end. A later phase advances past that wait before inspecting the child.
// The pinned-library run on Verilator 5.052 leaves the child task alive.
// Keep the normative expectation as a spec-only case pending root-cause triage.

module test_task_phase_kills_remaining_child_task;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class worker extends uvm_component;
    `uvm_component_utils(worker)
    bit entered = 0;
    bit late_write = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task pre_reset_phase(uvm_phase phase);
      entered = 1;
      #3;
      late_write = 1;
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
    task pre_reset_phase(uvm_phase phase);
      phase.raise_objection(this);
      #1;
      phase.drop_objection(this);
    endtask
    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      #4;
      $display("UT: child entered %0d late_write %0d", child.entered, child.late_write);
      phase.drop_objection(this);
    endtask
    function void extract_phase(uvm_phase phase);
      super.extract_phase(phase);
      $display("UT: elapsed %0d", $time);
    endfunction
  endclass
  initial run_test();
endmodule
