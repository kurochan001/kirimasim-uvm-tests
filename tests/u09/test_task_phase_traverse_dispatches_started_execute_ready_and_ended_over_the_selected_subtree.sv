/*
:name: test_task_phase_traverse_dispatches_started_execute_ready_and_ended_over_the_selected_subtree
:description: task phase traverse dispatches started execute ready and ended over the selected subtree
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.6.2.2 9.6.2.3 9.3.1.5.2 9.3.1.6.1 9.3.1.4.4 9.3.1.6.6 13.1.4.4.2 13.1.4.3.1 13.1.4.3.2 13.1.4.3.3 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_task_phase_traverse_dispatches_started_execute_ready_and_ended_over_the_selected_subtree.expected
*/
// What it checks:
// 1. Task traversal for STARTED dispatches phase_started to applicable subtree
//    components.
// 2. Task traversal for EXECUTING dispatches execute and the original
//    exec_task to applicable subtree components.
// 3. Task traversal for READY_TO_END dispatches phase_ready_to_end to
//    applicable subtree components.
// 4. Task traversal for ENDED dispatches phase_ended to applicable subtree
//    components.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.6.2.2 (UVM-PHASE-RUNTIME-TASK-TRAVERSE-STARTED) gives rule
//    1 above. Setup: A four-component subtree has a matching domain-attached
//    phase node and an excluded peer; the task implementation delays
//    completion. Expected: Each selected handle occurs once in the named state
//    queue, the peer is absent and context matches.
// 2. 1800.2-2020 9.6.2.2 (UVM-PHASE-RUNTIME-TASK-TRAVERSE-EXECUTING) gives
//    rule 2 above. Setup: A four-component subtree has a matching
//    domain-attached phase node and an excluded peer; the task implementation
//    delays completion. Expected: Each selected handle occurs once in the
//    named state queue, the peer is absent and context matches.
// 3. 1800.2-2020 9.6.2.2 (UVM-PHASE-RUNTIME-TASK-TRAVERSE-READY-TO-END) gives
//    rule 3 above. Setup: A four-component subtree has a matching
//    domain-attached phase node and an excluded peer; the task implementation
//    delays completion. Expected: Each selected handle occurs once in the
//    named state queue, the peer is absent and context matches.
// 4. 1800.2-2020 9.6.2.2 (UVM-PHASE-RUNTIME-TASK-TRAVERSE-ENDED) gives rule 4
//    above. Setup: A four-component subtree has a matching domain-attached
//    phase node and an excluded peer; the task implementation delays
//    completion. Expected: Each selected handle occurs once in the named state
//    queue, the peer is absent and context matches.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module
  test_task_phase_traverse_dispatches_started_execute_ready_and_ended_over_the_selected_subtree;
  import uvm_pkg::*;
  uvm_phase wanted;
  uvm_component starts[$],execs[$],ready[$],ends[$];
  bit contexts_ok=1;
  int completed=0;
  class worker extends uvm_component;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void phase_started(uvm_phase phase);
      starts.push_back(this);contexts_ok &= phase==wanted;
    endfunction
    virtual function void phase_ready_to_end(uvm_phase phase);
      ready.push_back(this);contexts_ok &= phase==wanted;
    endfunction
    virtual function void phase_ended(uvm_phase phase);
      ends.push_back(this);contexts_ok &= phase==wanted;
    endfunction
  endclass
  class original_task extends uvm_task_phase;
    function new();super.new("original54");endfunction
    virtual task exec_task(uvm_component comp,uvm_phase phase);
      execs.push_back(comp);contexts_ok &= phase==wanted;#2;completed++;
    endtask
  endclass
  function automatic bit selected_handles(uvm_component values[$],uvm_component a,
    uvm_component b,uvm_component c,uvm_component d);
    int counts[4]='{default:0};
    foreach (values[i]) begin
      if (values[i]==a) counts[0]++;else if (values[i]==b) counts[1]++;
      else if (values[i]==c) counts[2]++;else if (values[i]==d) counts[3]++;
      else return 0;
    end
    return values.size()==4 && counts[0]==1 && counts[1]==1 && counts[2]==1 && counts[3]==1;
  endfunction
  initial begin
    automatic worker root=new("tree54",null);
    automatic worker left=new("left54",root);
    automatic worker leaf=new("leaf54",left);
    automatic worker right=new("right54",root);
    automatic worker peer=new("peer54",null);
    automatic original_task imp=new();
    automatic uvm_phase schedule=new("manual54",UVM_PHASE_SCHEDULE);
    uvm_domain domain;
    uvm_phase node;
    domain=root.get_domain();schedule.add(imp);domain.add(schedule);node=schedule.find(imp);
    if (node==null || node.get_domain()!=domain) $fatal(1,"invalid task traversal context");
    wanted=node;
    imp.traverse(root,node,UVM_PHASE_STARTED);
    imp.traverse(root,node,UVM_PHASE_EXECUTING);
    $display("UT: task_traverse returned_early %0d",completed==0);
    #3;
    imp.traverse(root,node,UVM_PHASE_READY_TO_END);imp.traverse(root,node,UVM_PHASE_ENDED);
    $display("UT: task_traverse started %0d executed %0d ready %0d ended %0d",
      selected_handles(starts,root,left,leaf,right),selected_handles(execs,root,left,leaf,right),
      selected_handles(ready,root,left,leaf,right),selected_handles(ends,root,left,leaf,right));
    $display("UT: task_traverse complete %0d context %0d",completed==4,contexts_ok);
    $finish;
  end
  initial begin #100;$fatal(1,"task traversal watchdog");end
endmodule
