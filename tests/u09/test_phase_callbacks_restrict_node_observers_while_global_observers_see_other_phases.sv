/*
:name: test_phase_callbacks_restrict_node_observers_while_global_observers_see_other_phases
:description: phase callbacks restrict node observers while global observers see other phases
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.3 9.3.3.2.2 9.3.1.1.3 10.7.2.3.1 9.4.2.2 9.3.1.4.4 9.3.1.7.2 9.3.1.7.3 F.2.5.2 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_callbacks_restrict_node_observers_while_global_observers_see_other_phases.expected
*/
// What it checks:
// 1. A node-specific callback observes that node.
// 2. A type-wide phase callback can observe multiple phase nodes.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.3.3 (UVM-PHASE-CONTRACT-CALLBACK-NODE-SCOPE) gives rule 1
//    above. Setup: A type-wide callback and a callback registered on the
//    actual main node observe the same run. Expected: Required states are
//    present and local_other_none/selected_context are true.
// 2. 1800.2-2020 9.3.3 (UVM-PHASE-CONTRACT-CALLBACK-ALL-NODES) gives rule 2
//    above. Setup: A type-wide callback and a callback registered on the
//    actual main node observe the same run. Expected: The global callback
//    observes main states and other phases.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_phase_callbacks_restrict_node_observers_while_global_observers_see_other_phases;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  bit main_entered=0;
  class transition_probe extends uvm_phase_cb;
    int other=0;
    bit observed[uvm_phase_state];
    bit descriptor_matches=1,previous_chain=1,before_execute=0,default_no_effect=1;
    bit jump_null=1,object_views=1;
    bit have_previous=0;
    uvm_phase_state last;
    function new(string name);super.new(name);endfunction
    function bit has_required();
      return observed.exists(UVM_PHASE_STARTED) && observed.exists(UVM_PHASE_EXECUTING) &&
        observed.exists(UVM_PHASE_READY_TO_END) && observed.exists(UVM_PHASE_ENDED) &&
        observed.exists(UVM_PHASE_DONE);
    endfunction
    virtual function void phase_state_change(uvm_phase phase,uvm_phase_state_change change);
      uvm_phase_state current,previous;
      uvm_object object_view;
      uvm_phase_state_change back;
      if (phase.get_name()!="main") begin other++;return;end
      current=change.get_state();previous=change.get_prev_state();
      descriptor_matches &= current==phase.get_state();
      if (have_previous) previous_chain &= previous==last;
      last=current;have_previous=1;observed[current]=1;
      if (current==UVM_PHASE_EXECUTING) before_execute |= !main_entered;
      jump_null &= change.jump_to()==null;
      object_view=change;object_views &= $cast(back,object_view) && back==change;
      super.phase_state_change(phase,change);
      default_no_effect &= current==phase.get_state() && current==change.get_state();
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    transition_probe global_probe,local_probe;
    uvm_phase selected;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void build_phase(uvm_phase phase);
      uvm_domain domains[string];
      super.build_phase(phase);uvm_domain::get_domains(domains);
      if (!domains.exists("uvm")) $fatal(1,"missing runtime domain");
      selected=domains["uvm"].find(uvm_main_phase::get());
      if (selected==null) $fatal(1,"missing main node");
      global_probe=new("global53");local_probe=new("local53");
      uvm_callbacks#(uvm_phase,uvm_phase_cb)::add(null,global_probe);
      uvm_callbacks#(uvm_phase,uvm_phase_cb)::add(selected,local_probe);
    endfunction
    virtual task main_phase(uvm_phase phase);
      main_entered=1;phase.raise_objection(this);#2;phase.drop_objection(this);
    endtask

    virtual function void check_phase(uvm_phase phase);
      $display("UT: phase_callback_scope local_states %0d global_states %0d local_other_none %0d",
        local_probe.has_required(),global_probe.has_required(),
        local_probe.other==0);
      $display("UT: phase_callback_scope global_other %0d selected_context %0d",
        global_probe.other>0,local_probe.descriptor_matches && global_probe.descriptor_matches);
    endfunction
  endclass
  initial run_test("t");
  initial begin #100;$fatal(1,"phase callback scope watchdog");end
endmodule
