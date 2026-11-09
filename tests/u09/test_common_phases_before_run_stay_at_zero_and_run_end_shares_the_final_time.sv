/*
:name: test_common_phases_before_run_stay_at_zero_and_run_end_shares_the_final_time
:description: common phases before run stay at zero and run end shares the final time
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.8.1 9.8.1.5 9.8.1.9 9.6 9.3.1.7.2 9.3.1.7.3 13.1.4.3.1 13.1.4.3.3 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_common_phases_before_run_stay_at_zero_and_run_end_shares_the_final_time.expected
*/
// What it checks:
// 1. Common phases preceding run execute at time zero.
// 2. The run phase begins at simulation time zero.
// 3. The end of run has the same simulation time as final completion.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.8.1 (UVM-PHASE-RUNTIME-COMMON-PRE-RUN-ZERO) gives rule 1
//    above. Setup: Four overridden common hooks execute through the real phase
//    engine. Expected: All four hooks are observed and all their time samples
//    are zero.
// 2. 1800.2-2020 9.8.1.5 (UVM-PHASE-RUNTIME-RUN-START-ZERO) gives rule 2
//    above. Setup: A phase-start callback observes run before an
//    objection-held three-unit task. Expected: run_start_zero is true.
// 3. 1800.2-2020 9.8.1.5 (UVM-PHASE-RUNTIME-RUN-FINAL-ENDPOINT) gives rule 3
//    above. Setup: An objection holds run for positive time; its ended
//    callback records time and final samples it. Expected: Run has ended, its
//    end time equals final time and duration is positive.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_common_phases_before_run_stay_at_zero_and_run_end_shares_the_final_time;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    bit zero_times=1;
    int early_calls=0;
    bit run_started=0,run_ended=0;
    time run_end;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    function void early();early_calls++;zero_times &= $time==0;endfunction
    virtual function void build_phase(uvm_phase phase);super.build_phase(phase);early();endfunction
    virtual function void connect_phase(uvm_phase phase);early();endfunction
    virtual function void end_of_elaboration_phase(uvm_phase phase);early();endfunction
    virtual function void start_of_simulation_phase(uvm_phase phase);early();endfunction
    virtual function void phase_started(uvm_phase phase);
      if (phase.get_name()=="run") run_started=$time==0;
    endfunction
    virtual function void phase_ended(uvm_phase phase);
      if (phase.get_name()=="run") begin run_ended=1;run_end=$time;end
    endfunction
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);#3;phase.drop_objection(this);
    endtask
    virtual function void final_phase(uvm_phase phase);
      $display("UT: common_time pre_run_zero %0d four_hooks %0d run_start_zero %0d",
        zero_times,early_calls==4,run_started);
      $display("UT: common_time run_ended %0d final_same_time %0d positive_duration %0d",
        run_ended,run_ended && run_end==$time,run_end>0);
    endfunction
  endclass
  initial run_test("t");
  initial begin #100;$fatal(1,"common time watchdog");end
endmodule
