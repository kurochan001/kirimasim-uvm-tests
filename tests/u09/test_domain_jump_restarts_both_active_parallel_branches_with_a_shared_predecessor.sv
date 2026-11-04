/*
:name: test_domain_jump_restarts_both_active_parallel_branches_with_a_shared_predecessor
:description: domain jump restarts both active parallel branches with a shared predecessor
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.4.2.4 9.3.1.9 9.3.1.6.1 9.3.1.6.2 9.3.1.4.4 13.1.4.4.1 13.1.4.4.3 9.4.2.2 9.3.1.7.2 9.3.1.7.3 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_domain_jump_restarts_both_active_parallel_branches_with_a_shared_predecessor.expected
*/
module test_domain_jump_restarts_both_active_parallel_branches_with_a_shared_predecessor;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  int prep_calls=0,branch_calls[2]='{default:0},done_calls=0,peer_calls=0;
  bit peer_finished=0;
  class prep_phase extends uvm_task_phase;
    function new();super.new("prep54");endfunction
    virtual task exec_task(uvm_component comp,uvm_phase phase);
      prep_calls++;phase.raise_objection(comp);#1;phase.drop_objection(comp);
    endtask
  endclass
  class branch_phase extends uvm_task_phase;
    int lane;
    function new(string name,int index);super.new(name);lane=index;endfunction
    virtual task exec_task(uvm_component comp,uvm_phase phase);
      branch_calls[lane]++;phase.raise_objection(comp);
      if (branch_calls[lane]==1) begin forever #1;end
      else begin #2;phase.drop_objection(comp);end
    endtask
  endclass
  class done_phase extends uvm_task_phase;
    function new();super.new("done54");endfunction
    virtual task exec_task(uvm_component comp,uvm_phase phase);
      done_calls++;phase.raise_objection(comp);#1;phase.drop_objection(comp);
    endtask
  endclass
  class actor extends uvm_component;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
  endclass
  class peer_actor extends uvm_component;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual task main_phase(uvm_phase phase);
      peer_calls++;phase.raise_objection(this);#8;peer_finished=1;phase.drop_objection(this);
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    actor selected;
    peer_actor peer;
    uvm_domain domain;
    uvm_phase target;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void build_phase(uvm_phase phase);
      uvm_domain domains[string];
      uvm_phase schedule;
      prep_phase prep;
      branch_phase a,b;
      done_phase finish_imp;
      super.build_phase(phase);selected=new("selected54",this);peer=new("peer54",this);
      domain=new("jump_domain54");schedule=new("jump_schedule54",UVM_PHASE_SCHEDULE);
      prep=new();a=new("branch_a54",0);b=new("branch_b54",1);finish_imp=new();
      schedule.add(prep);schedule.add(a);schedule.add(b,.with_phase(a));schedule.add(finish_imp);
      domain.add(schedule);selected.set_domain(domain);target=domain.find(prep);
      uvm_domain::get_domains(domains);
      if (!domains.exists("common") || target==null) $fatal(1,"missing jump context");
      if (domain.get_parent()==null)
        domains["common"].add(domain,.with_phase(uvm_run_phase::get()));
    endfunction
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);wait(branch_calls[0]==1 && branch_calls[1]==1);
      #1;domain.jump(target);wait(done_calls==1 && peer_finished);#1;phase.drop_objection(this);
    endtask
    virtual function void check_phase(uvm_phase phase);
      $display("UT: domain_jump predecessor %0d both_branches %0d joined_once %0d peer_once %0d",
        prep_calls==2,branch_calls[0]==2 && branch_calls[1]==2,done_calls==1,
        peer_calls==1 && peer_finished);
    endfunction
  endclass
  initial run_test("t");
  initial begin #100;$fatal(1,"domain jump watchdog");end
endmodule
