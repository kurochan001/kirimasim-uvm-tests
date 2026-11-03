/*
:name: test_component_hierarchical_id_and_pair_verbosity_preserve_subtree_precedence_and_live_filtering
:description: component hierarchical id and pair verbosity preserve subtree precedence and live filtering
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.2.2.1 13.1.8 6.3.4.1 6.3.4.3 6.3.4.4 6.3.3.2 6.3.3.3 6.5.1.2.16 F.4.1.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_hierarchical_id_and_pair_verbosity_preserve_subtree_precedence_and_live_filtering.expected
*/
module
  test_component_hierarchical_id_and_pair_verbosity_preserve_subtree_precedence_and_live_filtering;
  import uvm_pkg::*;
  class node extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class observer_server extends uvm_default_report_server;
    int executions=0,counted=0,plain=0;
    int infos=0,warnings=0;
    virtual function string compose_report_message(uvm_report_message report_message,
                                                  string report_object_name="");
      return "original47";
    endfunction
    virtual function void execute_report_message(uvm_report_message report_message,
                                                string composed_message);
      executions++;
      if (report_message.get_severity()==UVM_INFO) infos++;
      if (report_message.get_severity()==UVM_WARNING) warnings++;
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
    branch.set_report_id_verbosity_hier("picked47",UVM_HIGH);
    branch.set_report_severity_id_verbosity_hier(UVM_WARNING,"picked47",UVM_DEBUG);
    foreach (nodes[i]) begin
      $display("UT: hierarchy_verbosity %0d id %0d pair %0d other %0d",i,
               nodes[i].get_report_verbosity_level(UVM_INFO,"picked47")==UVM_HIGH,
               nodes[i].get_report_verbosity_level(UVM_WARNING,"picked47")==UVM_DEBUG,
               nodes[i].get_report_verbosity_level(UVM_WARNING,"other47")==UVM_LOW);
      $display("UT: hierarchy_pair_enabled %0d boundary %0d above %0d",i,
               nodes[i].uvm_report_enabled(UVM_DEBUG,UVM_WARNING,"picked47"),
               nodes[i].uvm_report_enabled(UVM_DEBUG+1,UVM_WARNING,"picked47"));
      nodes[i].uvm_report_info("picked47","boundary",UVM_HIGH);
      nodes[i].uvm_report_info("picked47","above",UVM_HIGH+1);
      nodes[i].uvm_report_warning("picked47","pair boundary",UVM_DEBUG);
      nodes[i].uvm_report_warning("picked47","pair above",UVM_DEBUG+1);
    end
    // Actual WARNING reports ignore verbosity, unlike the configuration query.
    $display("UT: hierarchy_verbosity_delivery info %0d warning %0d total %0d",
             server.infos,server.warnings,server.executions);
    child.set_report_id_verbosity_hier("picked47",UVM_MEDIUM);
    correct=branch.get_report_verbosity_level(UVM_INFO,"picked47")==UVM_HIGH;
    correct &= child.get_report_verbosity_level(UVM_INFO,"picked47")==UVM_MEDIUM;
    correct &= leaf.get_report_verbosity_level(UVM_INFO,"picked47")==UVM_MEDIUM;
    foreach (nodes[i])
      correct &= nodes[i].get_report_verbosity_level(UVM_WARNING,"picked47")==UVM_DEBUG;
    $display("UT: hierarchy_verbosity_narrowed %0d peer %0d",correct,
             peer.get_report_verbosity_level(UVM_INFO,"picked47")==UVM_LOW &&
             peer.get_report_verbosity_level(UVM_WARNING,"picked47")==UVM_LOW);
    server.executions=0;
    foreach (all_nodes[i]) all_nodes[i].uvm_report_info("picked47","narrowed",UVM_HIGH);
    $display("UT: hierarchy_verbosity_narrowed_delivery %0d",server.executions);
    $finish;
  end
endmodule
