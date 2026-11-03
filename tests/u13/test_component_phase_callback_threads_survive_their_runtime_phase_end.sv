/*
:name: test_component_phase_callback_threads_survive_their_runtime_phase_end
:description: component phase callback threads survive their runtime phase end
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4.3 13.1.4.3.1 13.1.4.3.2 13.1.4.3.3 13.1.4.2.1 13.1.4.2.8 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_phase_callback_threads_survive_their_runtime_phase_end.expected
*/
module test_component_phase_callback_threads_survive_their_runtime_phase_end;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class callback_test extends uvm_test;
    `uvm_component_utils(callback_test)
    bit started_done=0,ready_done=0,ended_done=0,ready_spawned=0;
    bit started_spawned=0,ended_spawned=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function void phase_started(uvm_phase phase);
      super.phase_started(phase);
      if (phase.get_name()=="pre_reset") begin
        started_spawned=1; fork begin #4; started_done=1; end join_none
      end
    endfunction
    virtual function void phase_ready_to_end(uvm_phase phase);
      super.phase_ready_to_end(phase);
      if (phase.get_name()=="pre_reset" && !ready_spawned) begin
        ready_spawned=1; fork begin #4; ready_done=1; end join_none
      end
    endfunction
    virtual function void phase_ended(uvm_phase phase);
      super.phase_ended(phase);
      if (phase.get_name()=="pre_reset") begin
        ended_spawned=1; fork begin #4; ended_done=1; end join_none
      end
    endfunction
    virtual task pre_reset_phase(uvm_phase phase);
      phase.raise_objection(this); #1; phase.drop_objection(this);
    endtask
    virtual task main_phase(uvm_phase phase);
      phase.raise_objection(this); #6;
       $display("UT: callback_dispatch started %0d ready %0d ended %0d",
               started_spawned,ready_spawned,ended_spawned);
      $display("UT: callback_threads started %0d ready %0d ended %0d",
               started_done,ready_done,ended_done);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("callback_test");
  initial begin #100; $fatal(1,"callback lifetime watchdog"); end
endmodule
