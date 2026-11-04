/*
:name: test_task_phase_execute_forks_the_original_proxy_and_returns_before_its_delayed_completion
:description: task phase execute forks the original proxy and returns before its delayed completion
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.6.2.3 9.6.2.1 9.6.1 9.3.1.5.2 9.3.1.7.2 9.3.1.7.3 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_task_phase_execute_forks_the_original_proxy_and_returns_before_its_delayed_completion.expected
*/
module test_task_phase_execute_forks_the_original_proxy_and_returns_before_its_delayed_completion;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class original_task extends uvm_task_phase;
    bit entered=0,finished=0,arguments=0;
    uvm_component expected_component;
    uvm_phase expected_phase;
    function new();super.new("original53");endfunction
    virtual task exec_task(uvm_component comp,uvm_phase phase);
      entered=1;arguments=comp==expected_component && phase==expected_phase;
      #2;finished=1;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual task main_phase(uvm_phase phase);
      original_task imp;
      bit returned_before_done;
      phase.raise_objection(this);imp=new();imp.expected_component=this;imp.expected_phase=phase;
      imp.execute(this,phase);returned_before_done=!imp.finished;
      #1;
      $display("UT: task_execute returned_early %0d entered %0d not_yet_done %0d",
        returned_before_done,imp.entered,!imp.finished);
      #3;
      $display("UT: task_execute finished %0d arguments %0d implementation_kind %0d",
        imp.finished,imp.arguments,imp.get_phase_type()==UVM_PHASE_IMP);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100;$fatal(1,"task execute watchdog");end
endmodule
