/*
:name: test_run_test_callbacks_bracket_real_phasing_and_observe_core_lifecycle_states
:description: Deleting a later callback removes only that handle and preserves active peers through real phasing
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.6.2.6 F.6.2.2 F.6.2.3 F.6.2.5 F.2.10 F.3.1.1 F.3.1.2 F.7.3.1 F.7.3.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_run_test_callbacks_bracket_real_phasing_and_observe_core_lifecycle_states.expected
*/
// What it checks:
// Removing a later registered callback preserves earlier peers during real run
// notifications.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.6.2.6 (UVM-PACKAGE-AUDIT-CALLBACK-DELETE-DELIVERY) gives the
// rule above. Setup: Three distinct callbacks are registered in order, the
// third is deleted, then an actual test is phased with finish disabled.
// Expected: Both earlier callbacks receive pre/post exactly once; the deleted
// callback receives neither, and the test phases complete.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_run_test_callbacks_bracket_real_phasing_and_observe_core_lifecycle_states;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  int phase_visits=0;
  bit running_state=1;
  class callback_type extends uvm_run_test_callback;
    int pre_calls=0,post_calls=0;
    bit states_ok=1,ordering_ok=1;
    function new(string name); super.new(name); endfunction
    virtual function void pre_run_test();
      pre_calls++; states_ok &= get_core_state()==UVM_CORE_PRE_RUN;
      ordering_ok &= phase_visits==0;
    endfunction
    virtual function void post_run_test();
      post_calls++; states_ok &= get_core_state()==UVM_CORE_POST_RUN;
      ordering_ok &= phase_visits==2;
    endfunction
  endclass
  class test_type extends uvm_test;
    `uvm_component_utils(test_type)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase); phase_visits++;
      running_state &= get_core_state()==UVM_CORE_RUNNING;
    endfunction
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this); #1; phase_visits++;
      running_state &= get_core_state()==UVM_CORE_RUNNING; phase.drop_objection(this);
    endtask
  endclass
  initial begin
    automatic callback_type first_cb=new("first57");
    automatic callback_type second_cb=new("second57");
    automatic callback_type deleted_cb=new("deleted57");
    bit membership;
    membership=uvm_run_test_callback::add(first_cb) && uvm_run_test_callback::add(second_cb);
    membership &= uvm_run_test_callback::add(deleted_cb);
    membership &= uvm_run_test_callback::delete(deleted_cb);
    uvm_root::get().set_finish_on_completion(0); run_test("test_type");
    $display("UT: callback_lifecycle membership %0d both_pre %0d both_post %0d removed_absent %0d",
      membership,first_cb.pre_calls==1 && second_cb.pre_calls==1,
      first_cb.post_calls==1 && second_cb.post_calls==1,
      deleted_cb.pre_calls==0 && deleted_cb.post_calls==0);
    $display("UT: callback_deletion phases %0d finished %0d",
      phase_visits==2 && running_state,get_core_state()==UVM_CORE_FINISHED);
    $finish;
  end
  initial begin #100; $fatal(1,"callback lifecycle watchdog"); end
endmodule
