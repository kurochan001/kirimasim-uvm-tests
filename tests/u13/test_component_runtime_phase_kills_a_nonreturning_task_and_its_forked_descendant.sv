/*
:name: test_component_runtime_phase_kills_a_nonreturning_task_and_its_forked_descendant
:description: component runtime phase kills a nonreturning task and its forked descendant
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4.2 13.1.4 9.6 13.1.4.2.1 13.1.4.2.8 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_runtime_phase_kills_a_nonreturning_task_and_its_forked_descendant.expected
*/
// What it checks:
// 1. An ended runtime phase kills its selected unreturned component task.
// 2. An ended runtime phase kills the selected descendant forked by its
//    component task.
// 3. The component phase interface separates objection-controlled phase
//    lifetime from task return and ends selected task processes with the
//    phase.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.4.2 (UVM-COMPONENT-EXT-RUNTIME-TASK-KILL) gives rule 1
//    above. Setup: Use the linked original fixtures and their explicit public
//    phase, factory or hierarchy calls. Preserve the declared original types,
//    scope, arguments and expected observations; no private implementation
//    state supplies an oracle. Expected: An ended runtime phase kills its
//    selected unreturned component task.
// 2. 1800.2-2020 13.1.4.2 (UVM-COMPONENT-EXT-RUNTIME-DESCENDANT-KILL) gives
//    rule 2 above. Setup: Use the linked original fixtures and their explicit
//    public phase, factory or hierarchy calls. Preserve the declared original
//    types, scope, arguments and expected observations; no private
//    implementation state supplies an oracle. Expected: An ended runtime phase
//    kills the selected descendant forked by its component task.
// 3. 1800.2-2020 13.1.4 (UVM-COMPONENT-EXT-TASK-LIFETIME-INTERFACE) gives rule
//    3 above. Setup: Use the linked original fixtures and their explicit
//    public phase, factory or hierarchy calls. Preserve the declared original
//    types, scope, arguments and expected observations; no private
//    implementation state supplies an oracle. Expected: The component phase
//    interface separates objection-controlled phase lifetime from task return
//    and ends selected task processes with the phase.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_component_runtime_phase_kills_a_nonreturning_task_and_its_forked_descendant;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class lifetime_worker extends uvm_component;
    bit entered=0,forked=0,late_write=0;
    int ticks=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual task pre_reset_phase(uvm_phase phase);
      entered=1;
      fork begin forked=1; forever begin #1; ticks++; end end join_none
      #5; late_write=1;
      wait(0);
    endtask
  endclass
  class lifetime_test extends uvm_test;
    `uvm_component_utils(lifetime_test)
    lifetime_worker worker;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase); worker=new("worker",this);
    endfunction
    virtual task pre_reset_phase(uvm_phase phase);
      phase.raise_objection(this); #1; phase.drop_objection(this);
    endtask
    virtual task main_phase(uvm_phase phase);
      int before_ticks;
      phase.raise_objection(this); #1; before_ticks=worker.ticks; #6;
      $display("UT: runtime_lifetime entered %0d forked %0d late %0d fork_alive %0d",
               worker.entered,worker.forked,worker.late_write,worker.ticks>before_ticks);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("lifetime_test");
  initial begin #100; $fatal(1,"runtime lifetime watchdog"); end
endmodule
