/*
:name: test_domain_runtime_selected_different_then_unsync_preserves_the_selected_start_end_relationships
:description: domain runtime selected different then unsync preserves the selected start end relationships
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.8.2 9.3.1.8 9.3.1.8.1 9.3.1.8.2 9.3.1.1.3 13.1.4.4.1 13.1.4.4.2 13.1.4.4.3 9.3.1.4.4 9.3.1.7.2 9.3.1.7.3 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_domain_runtime_selected_different_then_unsync_preserves_the_selected_start_end_relationships.expected
*/
// What it checks:
// An explicit different-phase relationship can be removed with the same phase
// pair.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.3.1.8.2 (UVM-PHASE-RUNTIME-UNSYNC-EXPLICIT-DIFFERENT) gives
// the rule above. Setup: Two assigned domains execute original workers with
// unequal positive pre-reset/reset/main delays. Expected: Independent main
// progress and distinct simultaneous node states return after removal.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module
  test_domain_runtime_selected_different_then_unsync_preserves_the_selected_start_end_relationships;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  uvm_phase a_main,b_main;
  bit independent_states=0;
  class worker extends uvm_component;
    int lane;
    time reset_start,reset_end,main_start,main_end,post_main_start;
    int main_calls=0;
    bit reset_started=0,reset_ended=0,main_ended=0,post_started=0;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual task pre_reset_phase(uvm_phase phase);
      phase.raise_objection(this);if (lane==0) begin #1;end else begin #3;end
      phase.drop_objection(this);
    endtask
    virtual task reset_phase(uvm_phase phase);
      reset_started=1;reset_start=$time;phase.raise_objection(this);
      if (lane==0) begin #1;end else begin #4;end
      phase.drop_objection(this);
    endtask
    virtual task main_phase(uvm_phase phase);
      main_calls++;main_start=$time;phase.raise_objection(this);
      #1;
      if (lane==0)
        independent_states=a_main!=b_main && a_main.get_state()==UVM_PHASE_EXECUTING &&
          b_main.get_state()!=UVM_PHASE_EXECUTING;
      if (lane==0) begin #1;end else begin #3;end
      phase.drop_objection(this);
    endtask
    virtual function void phase_started(uvm_phase phase);
      if (phase.get_name()=="post_main") begin post_started=1;post_main_start=$time;end
    endfunction
    virtual function void phase_ended(uvm_phase phase);
      if (phase.get_name()=="reset") begin reset_ended=1;reset_end=$time;end
      if (phase.get_name()=="main") begin main_ended=1;main_end=$time;end
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    worker a,b;
    uvm_domain a_domain,b_domain;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);a=new("a54",this);b=new("b54",this);a.lane=0;b.lane=1;
      a_domain=new("a_domain54");b_domain=new("b_domain54");
      a.set_domain(a_domain);b.set_domain(b_domain);
      a_main=a_domain.find(uvm_main_phase::get());b_main=b_domain.find(uvm_main_phase::get());
      if (a_main==null || b_main==null) $fatal(1,"missing domain contexts");
      a_domain.sync(b_domain,uvm_main_phase::get(),uvm_reset_phase::get());
      a_domain.unsync(b_domain,uvm_main_phase::get(),uvm_reset_phase::get());
    endfunction
    virtual function void check_phase(uvm_phase phase);
      $display("UT: domain_relation independent_start %0d independent_end %0d states %0d",
        a.main_start<b.main_start,a.main_end<b.main_end,independent_states);
      $display("UT: domain_relation calls %0d contexts %0d",
        a.main_calls==1 && b.main_calls==1 && a.reset_started && b.reset_started &&
        a.reset_ended && b.reset_ended && a.main_ended && b.main_ended &&
        a.post_started && b.post_started,a.get_domain()==a_domain && b.get_domain()==b_domain);
    endfunction
  endclass
  initial run_test("t");
  initial begin #100;$fatal(1,"domain relation watchdog");end
endmodule
