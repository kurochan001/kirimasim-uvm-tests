/*
:name: test_runtime_phases_keep_their_default_order_do_not_overlap_and_join_before_extract
:description: runtime phases keep their default order do not overlap and join before extract
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.8.2 9.8 9.8.1.5 9.6 9.3.1.7.2 9.3.1.7.3 13.1.4.3.1 13.1.4.3.3 9.3.1.4.1 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_runtime_phases_keep_their_default_order_do_not_overlap_and_join_before_extract.expected
*/
// What it checks:
// 1. The predefined runtime phases follow their default execution order.
// 2. The predefined runtime phases do not overlap within the selected domain.
// 3. Runtime phases start only after start_of_simulation completes.
// 4. extract does not start before the runtime schedule ends.
// 5. The runtime schedule runs concurrently with the common run phase.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.8.2 (UVM-PHASE-RUNTIME-RUNTIME-DEFAULT-ORDER) gives rule 1
//    above. Setup: One real default domain executes all twelve hooks, each
//    held by an objection for two positive delay units. Expected: All twelve
//    starts and ends occur in order.
// 2. 1800.2-2020 9.8.2 (UVM-PHASE-RUNTIME-RUNTIME-NONOVERLAP) gives rule 2
//    above. Setup: One real default domain executes all twelve hooks, each
//    held by an objection for two positive delay units. Expected: At most one
//    runtime phase is active and none remains active at extract.
// 3. 1800.2-2020 9.8.2 (UVM-PHASE-RUNTIME-RUNTIME-AFTER-START) gives rule 3
//    above. Setup: One real default domain executes all twelve hooks, each
//    held by an objection for two positive delay units. Expected: Every
//    runtime start sees the completed start-of-simulation hook.
// 4. 1800.2-2020 9.8.2 (UVM-PHASE-RUNTIME-RUNTIME-BEFORE-EXTRACT) gives rule 4
//    above. Setup: One real default domain executes all twelve hooks, each
//    held by an objection for two positive delay units. Expected: Twelve
//    runtime ends precede extract and its time is no earlier than the last
//    end.
// 5. 1800.2-2020 9.8 (UVM-PHASE-RUNTIME-COMMON-RUNTIME-CONCURRENT) gives rule
//    5 above. Setup: The common run node is captured and its original task
//    advances a heartbeat every unit; all twelve runtime tasks sample it two
//    positive units apart. Expected: Each runtime sample sees the run body
//    entered, an advancing heartbeat and an EXECUTING or READY_TO_END run
//    node.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_runtime_phases_keep_their_default_order_do_not_overlap_and_join_before_extract;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    string names[12]='{
      "pre_reset","reset","post_reset","pre_configure","configure","post_configure",
      "pre_main","main","post_main","pre_shutdown","shutdown","post_shutdown"};
    int next_started=0,next_ended=0,active=0;
    bit order_ok=1,no_overlap=1,after_start=1,start_complete=0,run_live=0,parallel_run=1;
    time last_end;
    uvm_phase run_context;
    int run_ticks=0,last_run_ticks=0;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void start_of_simulation_phase(uvm_phase phase);start_complete=1;endfunction
    virtual function void phase_started(uvm_phase phase);
      if (phase.get_name()=="run") run_context=phase;
      foreach (names[i]) if (phase.get_name()==names[i]) begin
        order_ok &= next_started==i;next_started++;
        no_overlap &= active==0;active++;after_start &= start_complete;
      end
    endfunction
    virtual function void phase_ended(uvm_phase phase);
      foreach (names[i]) if (phase.get_name()==names[i]) begin
        order_ok &= next_ended==i;next_ended++;active--;last_end=$time;
      end
    endfunction
    virtual task run_phase(uvm_phase phase);
      run_live=1;forever begin #1;run_ticks++;end
    endtask
    task hold_phase(uvm_phase phase);
      phase.raise_objection(this);#2;
      // Two-unit intervals avoid prescribing the order of same-time processes.
      parallel_run &= run_live && run_ticks>last_run_ticks;last_run_ticks=run_ticks;
      if (run_context==null) parallel_run=0;
      else parallel_run &= (run_context.get_state()==UVM_PHASE_EXECUTING ||
                            run_context.get_state()==UVM_PHASE_READY_TO_END);
      phase.drop_objection(this);
    endtask
    virtual task pre_reset_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual task reset_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual task post_reset_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual task pre_configure_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual task configure_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual task post_configure_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual task pre_main_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual task main_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual task post_main_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual task pre_shutdown_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual task shutdown_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual task post_shutdown_phase(uvm_phase phase);hold_phase(phase);endtask
    virtual function void extract_phase(uvm_phase phase);
      $display("UT: runtime_schedule twelve_starts %0d twelve_ends %0d order %0d",
        next_started==12,next_ended==12,order_ok);
    $display("UT: runtime_schedule nonoverlap %0d after_start %0d before_extract %0d parallel %0d",
        no_overlap && active==0,after_start,next_ended==12 && $time>=last_end,parallel_run);
    endfunction
  endclass
  initial run_test("t");
  initial begin #100;$fatal(1,"runtime order watchdog");end
endmodule
