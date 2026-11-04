/*
:name: test_phase_backward_jump_reexecutes_nodes_and_counts_runs_independently_of_component_calls
:description: phase backward jump reexecutes nodes and counts runs independently of component calls
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.9.1 9.3.1.9.4 9.3.2.2.3 9.3.1.4.2 9.3.1.4.4 9.3.1.7.2 9.3.1.7.3 9.3.3.2.2 10.7.2.3.1 9.8.2.7 9.8.2.8 F.2.5.2 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_backward_jump_reexecutes_nodes_and_counts_runs_independently_of_component_calls.expected
*/
module test_phase_backward_jump_reexecutes_nodes_and_counts_runs_independently_of_component_calls;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  uvm_phase expected_target;
  class jump_probe extends uvm_phase_cb;
    bit target_seen=0,descriptor_target=1,getter_target=1;
    virtual function void phase_state_change(uvm_phase phase,uvm_phase_state_change change);
      if (phase.get_name()=="main" && expected_target!=null &&
          change.get_state()==UVM_PHASE_JUMPING) begin
        target_seen=1;descriptor_target &= change.jump_to()==expected_target;
        getter_target &= phase.get_jump_target()==expected_target;
      end
    endfunction
  endclass
  class peer_type extends uvm_component;
    int calls=0;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual task main_phase(uvm_phase phase);calls++;endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    int calls=0,premains=0;
    bit ended_counts=1;
    uvm_phase main_node;
    peer_type peer;
    jump_probe probe;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);peer=new("peer53",this);probe=new();
      uvm_callbacks#(uvm_phase,uvm_phase_cb)::add(null,probe);
    endfunction
    virtual task pre_main_phase(uvm_phase phase);premains++;endtask
    virtual task main_phase(uvm_phase phase);
      main_node=phase;calls++;phase.raise_objection(this);#2;
      if (calls>2) $fatal(1,"unexpected repeated jump");
      phase.drop_objection(this);
      if (calls==1) begin
        expected_target=phase.find(uvm_pre_main_phase::get());
        if (expected_target==null) $fatal(1,"missing jump target");
        phase.jump(expected_target);
      end
    endtask
    virtual function void phase_ended(uvm_phase phase);
      super.phase_ended(phase);
      if (phase.get_name()=="main") ended_counts &= phase.get_run_count()==calls;
    endfunction
    virtual function void check_phase(uvm_phase phase);
      $display("UT: phase_jump main_runs %0d pre_main_runs %0d peer_calls %0d node_runs %0d",
        calls,premains,peer.calls,main_node.get_run_count());
      $display("UT: phase_jump ended_counts %0d target_seen %0d getter %0d descriptor %0d",
        ended_counts,probe.target_seen,probe.getter_target,probe.descriptor_target);
    endfunction
  endclass
  initial run_test("t");
  initial begin #100;$fatal(1,"phase jump watchdog");end
endmodule
