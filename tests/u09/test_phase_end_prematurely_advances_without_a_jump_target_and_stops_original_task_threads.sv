/*
:name: test_phase_end_prematurely_advances_without_a_jump_target_and_stops_original_task_threads
:description: phase end prematurely advances without a jump target and stops original task threads
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.9.3 9.3.1.9.4 9.6 9.3.1.7.2 9.3.1.7.3 9.8.1.5 9.8.2.8 9.8.2.9 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_end_prematurely_advances_without_a_jump_target_and_stops_original_task_threads.expected
*/
module test_phase_end_prematurely_advances_without_a_jump_target_and_stops_original_task_threads;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    bit requested=0,post_seen=0,no_target=0,stopped=0;
    int ticks=0;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual task main_phase(uvm_phase phase);
      phase.raise_objection(this);#1;requested=1;
      phase.end_prematurely();
      forever begin #1;ticks++;end
    endtask
    virtual function void phase_ended(uvm_phase phase);
      super.phase_ended(phase);
      if (phase.get_name()=="main") no_target=phase.get_jump_target()==null;
    endfunction
    virtual task post_main_phase(uvm_phase phase);post_seen=1;endtask
    virtual task run_phase(uvm_phase phase);
      int sampled;
      phase.raise_objection(this);wait(requested);#3;sampled=ticks;#3;
      stopped=ticks==sampled;phase.drop_objection(this);
    endtask
    virtual function void check_phase(uvm_phase phase);
      $display("UT: phase_premature post_reached %0d no_target %0d original_task_stopped %0d",
        post_seen,no_target,stopped);
    endfunction
  endclass
  initial run_test("t");
  initial begin #100;$fatal(1,"end prematurely watchdog");end
endmodule
