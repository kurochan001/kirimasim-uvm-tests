/*
:name: test_run_test_callbacks_without_deletion_observe_each_registered_hook_and_core_states
:description: Isolated registered callbacks expose normal run hooks and core states without a deletion operation
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.6.2.2 F.6.2.3 F.6.2.5 F.2.10 F.3.1.1 F.3.1.2 F.7.3.1 F.7.3.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_run_test_callbacks_without_deletion_observe_each_registered_hook_and_core_states.expected
*/
// What it checks:
// 1. All registered pre-run callbacks execute before real component phasing.
// 2. All registered post-run callbacks execute after phasing and before
//    run_test returns.
// 3. Selected core lifecycle enum states describe the observed run boundaries.
// 4. The package run_test convenience task drives the implicit root test
//    execution.
// 5. Root run execution brackets phasing with pre/post notifications and
//    finishes before return.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.6.2.2 (UVM-PACKAGE-AUDIT-CALLBACK-PRE-RUN) gives rule 1
//    above. Setup: Two registered callbacks and one unregistered control
//    surround an actual factory-created test with build and delayed run
//    phases; finish_on_completion is explicitly false. Expected: Both active
//    callbacks run once before either observed phase visit; the unregistered
//    callback remains absent.
// 2. 1800.2-2020 F.6.2.3 (UVM-PACKAGE-AUDIT-CALLBACK-POST-RUN) gives rule 2
//    above. Setup: Two registered callbacks and one unregistered control
//    surround an actual factory-created test with build and delayed run
//    phases; finish_on_completion is explicitly false. Expected: Both active
//    callbacks run once after both phase visits; the unregistered callback
//    remains absent.
// 3. 1800.2-2020 F.2.10 (UVM-PACKAGE-AUDIT-CORE-RUN-STATES) gives rule 3
//    above. Setup: Two registered callbacks and one unregistered control
//    surround an actual factory-created test with build and delayed run
//    phases; finish_on_completion is explicitly false. Expected: Pre callbacks
//    observe PRE_RUN, phase bodies RUNNING, post callbacks POST_RUN and the
//    caller FINISHED.
// 4. 1800.2-2020 F.3.1.2 (UVM-PACKAGE-AUDIT-GLOBAL-RUN-DELEGATION) gives rule
//    4 above. Setup: Two registered callbacks and one unregistered control
//    surround an actual factory-created test with build and delayed run
//    phases; finish_on_completion is explicitly false. Expected: The named
//    factory test executes both selected phases and registered run callbacks,
//    then returns under the explicit finish control.
// 5. 1800.2-2020 F.7.3.1 (UVM-PACKAGE-AUDIT-ROOT-RUN-BOUNDARIES) gives rule 5
//    above. Setup: Two registered callbacks and one unregistered control
//    surround an actual factory-created test with build and delayed run
//    phases; finish_on_completion is explicitly false. Expected: Observed
//    notifications, running phases and caller state follow the prescribed
//    PRE_RUN/RUNNING/POST_RUN/FINISHED progression.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_run_test_callbacks_without_deletion_observe_each_registered_hook_and_core_states;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  int phase_visits=0;
  bit running_state=1;
  class callback_type extends uvm_run_test_callback;
    int pre_calls=0,post_calls=0;
    bit pre_state_ok=1,post_state_ok=1,ordering_ok=1;
    uvm_core_state pre_state,post_state;
    function new(string name); super.new(name); endfunction
    virtual function void pre_run_test();
      pre_calls++; pre_state=get_core_state(); pre_state_ok &= pre_state==UVM_CORE_PRE_RUN;
      ordering_ok &= phase_visits==0;
    endfunction
    virtual function void post_run_test();
      post_calls++; post_state=get_core_state(); post_state_ok &= post_state==UVM_CORE_POST_RUN;
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
    uvm_root::get().set_finish_on_completion(0); run_test("test_type");
    $display("UT: callback_lifecycle membership %0d both_pre %0d both_post %0d removed_absent %0d",
      membership,first_cb.pre_calls==1 && second_cb.pre_calls==1,
      first_cb.post_calls==1 && second_cb.post_calls==1,
      deleted_cb.pre_calls==0 && deleted_cb.post_calls==0);
    $display(
      "UT: callback_lifecycle pre_state %0d post_state %0d ordering %0d running %0d finished %0d",
      first_cb.pre_state_ok && second_cb.pre_state_ok,
      first_cb.post_state_ok && second_cb.post_state_ok,
      first_cb.ordering_ok && second_cb.ordering_ok,
      running_state,get_core_state()==UVM_CORE_FINISHED);
    $display("UT: callback_state_names first_pre %s second_pre %s first_post %s second_post %s",
      first_cb.pre_state.name(),second_cb.pre_state.name(),
      first_cb.post_state.name(),second_cb.post_state.name());
    $finish;
  end
  initial begin #100; $fatal(1,"callback lifecycle watchdog"); end
endmodule
