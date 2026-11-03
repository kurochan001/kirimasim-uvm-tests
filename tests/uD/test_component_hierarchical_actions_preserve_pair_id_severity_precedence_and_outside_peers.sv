/*
:name: test_component_hierarchical_actions_preserve_pair_id_severity_precedence_and_outside_peers
:description: component hierarchical actions preserve pair id severity precedence and outside peers
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.2.2.2 13.1.8 6.3.5.1 6.3.5.2 6.3.3.3 6.5.1.2.16 F.4.1.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_hierarchical_actions_preserve_pair_id_severity_precedence_and_outside_peers.expected
*/
module test_component_hierarchical_actions_preserve_pair_id_severity_precedence_and_outside_peers;
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
    foreach (all_nodes[i]) begin
      all_nodes[i].set_report_severity_action(UVM_INFO,UVM_NO_ACTION);
      all_nodes[i].set_report_severity_action(UVM_WARNING,UVM_NO_ACTION);
    end
    branch.set_report_severity_action_hier(UVM_WARNING,UVM_DISPLAY);
    branch.set_report_id_action_hier("picked47",UVM_DISPLAY|UVM_COUNT);
    branch.set_report_severity_id_action_hier(UVM_WARNING,"picked47",UVM_NO_ACTION);
    foreach (nodes[i]) begin
      $display("UT: hierarchy_action %0d severity %0d id %0d pair %0d",i,
               nodes[i].get_report_action(UVM_WARNING,"other47")==UVM_DISPLAY,
               nodes[i].get_report_action(UVM_INFO,"picked47")== (UVM_DISPLAY|UVM_COUNT),
               nodes[i].get_report_action(UVM_WARNING,"picked47")==UVM_NO_ACTION);
      nodes[i].uvm_report_info("picked47","id",UVM_NONE);
      nodes[i].uvm_report_warning("picked47","suppressed",UVM_NONE);
      nodes[i].uvm_report_warning("other47","severity",UVM_NONE);
    end
    $display("UT: hierarchy_action_delivery total %0d id %0d severity %0d",
             server.executions,server.counted,server.plain);
    child.set_report_severity_action_hier(UVM_WARNING,UVM_NO_ACTION);
    correct=branch.get_report_action(UVM_WARNING,"other47")==UVM_DISPLAY;
    correct &= child.get_report_action(UVM_WARNING,"other47")==UVM_NO_ACTION;
    correct &= leaf.get_report_action(UVM_WARNING,"other47")==UVM_NO_ACTION;
    correct &= child.get_report_action(UVM_INFO,"picked47")== (UVM_DISPLAY|UVM_COUNT);
    $display("UT: hierarchy_action_narrowed %0d peer %0d",correct,
             peer.get_report_action(UVM_WARNING,"other47")==UVM_NO_ACTION &&
             peer.get_report_action(UVM_INFO,"picked47")==UVM_NO_ACTION);
    server.executions=0;
    child.uvm_report_warning("other47","suppressed",UVM_NONE);
    branch.uvm_report_warning("other47","ancestor",UVM_NONE);
    child.uvm_report_info("picked47","id survives",UVM_NONE);
    $display("UT: hierarchy_action_narrowed_delivery %0d",server.executions);
    $finish;
  end
endmodule
