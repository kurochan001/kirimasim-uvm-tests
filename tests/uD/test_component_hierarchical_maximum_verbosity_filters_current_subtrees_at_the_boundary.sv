/*
:name: test_component_hierarchical_maximum_verbosity_filters_current_subtrees_at_the_boundary
:description: component hierarchical maximum verbosity filters current subtrees at the boundary
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.2.2.4 13.1.8 6.3.4.2 6.3.4.3 6.3.3.3 6.5.1.2.16 F.4.1.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_hierarchical_maximum_verbosity_filters_current_subtrees_at_the_boundary.expected
*/
module test_component_hierarchical_maximum_verbosity_filters_current_subtrees_at_the_boundary;
  import uvm_pkg::*;
  class node extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class observer_server extends uvm_default_report_server;
    int executions=0,counted=0,plain=0;
    virtual function string compose_report_message(uvm_report_message report_message,
                                                  string report_object_name="");
      return "original47";
    endfunction
    virtual function void execute_report_message(uvm_report_message report_message,
                                                string composed_message);
      executions++;
      if (report_message.get_action()==(UVM_DISPLAY|UVM_COUNT)) counted++;
      if (report_message.get_action()==UVM_DISPLAY) plain++;
    endfunction
  endclass
  initial begin
    automatic node branch=new("branch47",null);
    automatic node child=new("child",branch);
    automatic node leaf=new("leaf",child);
    automatic node peer=new("peer47",null);
    automatic uvm_component nodes[3]='{branch,child,leaf};
    automatic uvm_component all_nodes[4]='{branch,child,leaf,peer};
    automatic observer_server server=new();
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    bit correct;
    service.set_report_server(server);
    foreach (all_nodes[i]) all_nodes[i].set_report_verbosity_level(UVM_LOW);
    branch.set_report_verbosity_level_hier(UVM_MEDIUM);
    correct=1;
    foreach (nodes[i]) begin
      correct &= nodes[i].get_report_max_verbosity_level()==UVM_MEDIUM;
      nodes[i].uvm_report_info("plain47","boundary",UVM_MEDIUM);
      nodes[i].uvm_report_info("plain47","above",UVM_MEDIUM+1);
    end
    peer.uvm_report_info("plain47","outside",UVM_MEDIUM);
    $display("UT: hierarchy_max selected %0d peer %0d delivered %0d",correct,
             peer.get_report_max_verbosity_level()==UVM_LOW,server.executions);
    child.set_report_verbosity_level_hier(UVM_HIGH); server.executions=0;
    correct=branch.get_report_max_verbosity_level()==UVM_MEDIUM;
    correct &= child.get_report_max_verbosity_level()==UVM_HIGH;
    correct &= leaf.get_report_max_verbosity_level()==UVM_HIGH;
    foreach (all_nodes[i]) all_nodes[i].uvm_report_info("plain47","narrowed",UVM_HIGH);
    $display("UT: hierarchy_max_narrowed %0d peer %0d delivered %0d",correct,
             peer.get_report_max_verbosity_level()==UVM_LOW,server.executions);
    $finish;
  end
endmodule
