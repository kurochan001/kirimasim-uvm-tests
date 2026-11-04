/*
:name: test_phase_unattached_states_and_singleton_graph_nodes_keep_definition_and_context_distinct
:description: phase unattached states and singleton graph nodes keep definition and context distinct
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.1.3 9.3.1.1.1 9.3.1.1.2 9.3.1.2 9.3.1.3.1 9.3.1.4.1 9.3.1.6.1 9.3.1.4.4 9.6.2.1 F.2.5.2 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_unattached_states_and_singleton_graph_nodes_keep_definition_and_context_distinct.expected
*/
module test_phase_unattached_states_and_singleton_graph_nodes_keep_definition_and_context_distinct;
  import uvm_pkg::*;
  class task_imp extends uvm_task_phase;
    static task_imp singleton;
    function new(string name="singleton53");super.new(name);endfunction
    static function task_imp get();
      if (singleton==null) singleton=new();return singleton;
    endfunction
    virtual task exec_task(uvm_component comp,uvm_phase phase);endtask
  endclass

  initial begin
    automatic task_imp imp=task_imp::get();
    automatic uvm_phase unattached=new("unattached53",UVM_PHASE_NODE);
    automatic uvm_phase left=new("left53",UVM_PHASE_SCHEDULE);
    automatic uvm_phase right=new("right53",UVM_PHASE_SCHEDULE);
    uvm_phase first,second,back;
    uvm_object object_view;
    $display("UT: phase_initial imp_uninitialized %0d bare_node_uninitialized %0d singleton %0d",
      imp.get_state()==UVM_PHASE_UNINITIALIZED,unattached.get_state()==UVM_PHASE_UNINITIALIZED,
      imp==task_imp::get());
    left.add(imp);right.add(imp);first=left.find(imp);second=right.find(imp);
    object_view=first;
    $display("UT: phase_context distinct_nodes %0d left_parent %0d right_parent %0d object %0d",
      first!=null && second!=null && first!=second,first.get_parent()==left,
      second.get_parent()==right,$cast(back,object_view) && back==first);
    $display("UT: phase_context dormant %0d implementation_type %0d",
      first.get_state()==UVM_PHASE_DORMANT && second.get_state()==UVM_PHASE_DORMANT,
      imp.get_phase_type()==UVM_PHASE_IMP);
    $finish;
  end
endmodule
