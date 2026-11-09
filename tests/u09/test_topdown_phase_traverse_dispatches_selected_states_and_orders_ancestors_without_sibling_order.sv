/*
:name: test_topdown_phase_traverse_dispatches_selected_states_and_orders_ancestors_without_sibling_order
:description: topdown phase traverse dispatches selected states and orders ancestors without sibling order
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.7.2.2 9.7.2.3 9.7.2.1 9.7.1 9.3.1.5.1 13.1.4.3.1 13.1.4.3.3 9.3.1.3.1 9.3.1.6.1 9.3.1.4.4 9.3.1.6.6 13.1.4.4.2 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_topdown_phase_traverse_dispatches_selected_states_and_orders_ancestors_without_sibling_order.expected
*/
// What it checks:
// 1. The original topdown extension is initialized as an IMP.
// 2. The selected state traversal visits ancestors before descendants.
// 3. execute delegates to the original exec_func with component and phase
//    context.
// 4. The function proxy receives the originating component and phase context.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.7.2.1 (UVM-PHASE-CONTRACT-TOPDOWN-CTOR-IMP) gives rule 1
//    above. Setup: A four-component subtree is traversed for STARTED,
//    EXECUTING and ENDED using a node attached to the components' domain.
//    Expected: implementation_kind is true.
// 2. 1800.2-2020 9.7.2.2 (UVM-PHASE-CONTRACT-TOPDOWN-TRAVERSE) gives rule 2
//    above. Setup: A four-component subtree is traversed for STARTED,
//    EXECUTING and ENDED using a node attached to the components' domain.
//    Expected: All four selected handles occur once in each state with
//    ancestor order and no peer.
// 3. 1800.2-2020 9.7.2.3 (UVM-PHASE-CONTRACT-TOPDOWN-EXECUTE) gives rule 3
//    above. Setup: A four-component subtree is traversed for STARTED,
//    EXECUTING and ENDED using a node attached to the components' domain.
//    Expected: The execution queue has the expected handles and each call
//    retains the context node.
// 4. 1800.2-2020 9.3.1.5.1 (UVM-PHASE-CONTRACT-EXEC-FUNC-CONTEXT) gives rule 4
//    above. Setup: A four-component subtree is traversed for STARTED,
//    EXECUTING and ENDED using a node attached to the components' domain.
//    Expected: The selected execution handles and context comparisons match.
// It also supports, as a control, the setup or conditions of
// UVM-PHASE-CONTRACT-TOPDOWN-VIRTUAL.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Traverse a selected subtree; no sibling iteration order is imposed.
module
  test_topdown_phase_traverse_dispatches_selected_states_and_orders_ancestors_without_sibling_order;
  import uvm_pkg::*;
  uvm_phase expected_context;
  uvm_component starts[$],execs[$],ends[$];
  bit context_matches=1;
  class tree_component extends uvm_component;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void phase_started(uvm_phase phase);
      starts.push_back(this);context_matches &= phase==expected_context;
    endfunction
    virtual function void phase_ended(uvm_phase phase);
      ends.push_back(this);context_matches &= phase==expected_context;
    endfunction
  endclass
  function automatic bit ordered(uvm_component values[$],uvm_component root,
    uvm_component left,uvm_component leaf,uvm_component right,bit topdown);
    int r=-1,l=-1,f=-1,b=-1;
    foreach (values[i]) begin
      if (values[i]==root) r=i;if (values[i]==left) l=i;
      if (values[i]==leaf) f=i;if (values[i]==right) b=i;
    end
    if (values.size()!=4 || r<0 || l<0 || f<0 || b<0) return 0;
    return topdown ? r<l && l<f && r<b : f<l && l<r && b<r;
  endfunction

  class original_phase extends uvm_topdown_phase;
    function new();super.new("original53");endfunction
    virtual function void exec_func(uvm_component comp,uvm_phase phase);
      execs.push_back(comp);context_matches &= phase==expected_context;
    endfunction
  endclass
  initial begin
    automatic tree_component root=new("tree53",null);
    automatic tree_component left=new("left53",root);
    automatic tree_component leaf=new("leaf53",left);
    automatic tree_component right=new("right53",root);
    automatic tree_component peer=new("peer53",null);
    automatic original_phase imp=new();
    automatic uvm_phase context_schedule=new("manual_schedule53",UVM_PHASE_SCHEDULE);
    uvm_phase context_node;
    uvm_domain owner_domain;
    owner_domain=root.get_domain();
    if (owner_domain==null) $fatal(1,"missing component domain");
    context_schedule.add(imp);owner_domain.add(context_schedule);
    context_node=context_schedule.find(imp);
    if (context_node==null || context_node.get_domain()!=owner_domain)
      $fatal(1,"invalid traversal context");
    expected_context=context_node;
    imp.traverse(root,context_node,UVM_PHASE_STARTED);
    imp.traverse(root,context_node,UVM_PHASE_EXECUTING);
    imp.traverse(root,context_node,UVM_PHASE_ENDED);
    $display("UT: topdown_traverse start_order %0d execute_order %0d end_order %0d",
      ordered(starts,root,left,leaf,right,1),ordered(execs,root,left,leaf,right,1),
      ordered(ends,root,left,leaf,right,1));
    $display("UT: topdown_traverse context %0d implementation_kind %0d",
      context_matches,imp.get_phase_type()==UVM_PHASE_IMP);
    $finish;
  end
endmodule
