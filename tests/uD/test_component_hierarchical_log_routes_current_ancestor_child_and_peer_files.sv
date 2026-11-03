/*
:name: test_component_hierarchical_log_routes_current_ancestor_child_and_peer_files
:description: component hierarchical log routes current ancestor child and peer files
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.2.2 D.2.2.3 13.1.8 6.3.3.3 6.3.5.2 6.3.6.1 6.5.1.2.16 F.4.1.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_hierarchical_log_routes_current_ancestor_child_and_peer_files.expected
*/
module test_component_hierarchical_log_routes_current_ancestor_child_and_peer_files;
  import uvm_pkg::*;
  class node extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class original_formatter extends uvm_default_report_server;
    virtual function string compose_report_message(uvm_report_message report_message,
                                                  string report_object_name="");
      return report_message.get_message();
    endfunction
  endclass
  function automatic bit contains_payload(string path,string token);
    automatic int fd=$fopen(path,"r");
    automatic string all_text="";
    string line;
    bit found;
    if (!fd) $fatal(1,"cannot reopen log");
    while ($fgets(line,fd)) all_text={all_text,line};
    $fclose(fd); found=0;
    for (int i=0;i+token.len()<=all_text.len();i++)
      if (all_text.substr(i,i+token.len()-1)==token) found=1;
    return found;
  endfunction
  initial begin
    automatic node branch=new("branch47",null);
    automatic node child=new("child",branch);
    automatic node leaf=new("leaf",child);
    automatic node peer=new("peer47",null);
    automatic uvm_component nodes[4]='{branch,child,leaf,peer};
    automatic original_formatter formatter=new();
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    automatic int ancestor_fd=$fopen("ancestor47.txt","w");
    automatic int nested_fd=$fopen("nested47.txt","w");
    automatic int peer_fd=$fopen("peer47.txt","w");
    if (!ancestor_fd || !nested_fd || !peer_fd) $fatal(1,"cannot open fixture logs");
    service.set_report_server(formatter);
    foreach (nodes[i]) nodes[i].set_report_id_action("log47",UVM_LOG);
    branch.set_report_default_file_hier(ancestor_fd);
    child.set_report_default_file_hier(nested_fd); peer.set_report_default_file(peer_fd);
    branch.uvm_report_info("log47","ancestor_payload47",UVM_NONE);
    child.uvm_report_info("log47","child_payload47",UVM_NONE);
    leaf.uvm_report_info("log47","leaf_payload47",UVM_NONE);
    peer.uvm_report_info("log47","peer_payload47",UVM_NONE);
    $fclose(ancestor_fd); $fclose(nested_fd); $fclose(peer_fd);
    $display("UT: hierarchy_log ancestor %0d nested %0d peer %0d isolation %0d",
             contains_payload("ancestor47.txt","ancestor_payload47"),
             contains_payload("nested47.txt","child_payload47") &&
             contains_payload("nested47.txt","leaf_payload47"),
             contains_payload("peer47.txt","peer_payload47"),
             !contains_payload("ancestor47.txt","child_payload47") &&
             !contains_payload("ancestor47.txt","leaf_payload47") &&
             !contains_payload("ancestor47.txt","peer_payload47") &&
             !contains_payload("nested47.txt","ancestor_payload47") &&
             !contains_payload("nested47.txt","peer_payload47") &&
             !contains_payload("peer47.txt","ancestor_payload47") &&
             !contains_payload("peer47.txt","child_payload47") &&
             !contains_payload("peer47.txt","leaf_payload47"));
    $finish;
  end
endmodule
