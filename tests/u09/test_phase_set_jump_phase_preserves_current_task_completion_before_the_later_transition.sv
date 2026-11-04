/*
:name: test_phase_set_jump_phase_preserves_current_task_completion_before_the_later_transition
:description: phase set jump phase preserves current task completion before the later transition
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.9.2 9.3.1.9.4 9.3.1.4.4 9.3.1.7.2 9.3.1.7.3 9.8.2.7 9.8.2.8 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_set_jump_phase_preserves_current_task_completion_before_the_later_transition.expected
*/
module test_phase_set_jump_phase_preserves_current_task_completion_before_the_later_transition;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    int calls=0,premains=0,completed_delays=0;
    bit target_match=0;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual task pre_main_phase(uvm_phase phase);premains++;endtask
    virtual task main_phase(uvm_phase phase);
      uvm_phase target;
      calls++;if (calls>2) $fatal(1,"unexpected repeated target");phase.raise_objection(this);
      if (calls==1) begin
        target=phase.find(uvm_pre_main_phase::get());
        if (target==null) $fatal(1,"missing target");
        phase.set_jump_phase(target);target_match=phase.get_jump_target()==target;
        #2;completed_delays++;
      end else begin #2;completed_delays++;end
      phase.drop_objection(this);
    endtask
    virtual function void check_phase(uvm_phase phase);
      $display("UT: phase_set_jump main_runs %0d pre_main_runs %0d completed_delays %0d target %0d",
        calls,premains,completed_delays,target_match);
    endfunction
  endclass
  initial run_test("t");
  initial begin #100;$fatal(1,"set jump phase watchdog");end
endmodule
