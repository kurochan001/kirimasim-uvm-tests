uvm_component visits91[$];
uvm_phase expected_node91;
bit node_matches91=1;
class component91 extends uvm_component;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
endclass
class down91 extends uvm_topdown_phase;
  function new();
    super.new("down91");
  endfunction
  virtual function void exec_func(uvm_component comp,uvm_phase phase);
    visits91.push_back(comp);
    node_matches91 &= phase==expected_node91;
  endfunction
endclass
class up91 extends uvm_bottomup_phase;
  function new();
    super.new("up91");
  endfunction
  virtual function void exec_func(uvm_component comp,uvm_phase phase);
    visits91.push_back(comp);
    node_matches91 &= phase==expected_node91;
  endfunction
endclass
function automatic bit ordered91(uvm_component root,uvm_component branch,
    uvm_component leaf,uvm_component other,bit topdown);
  automatic int r=-1,b=-1,l=-1,o=-1;
  foreach (visits91[i]) begin
    if (visits91[i]==root) r=i;
    if (visits91[i]==branch) b=i;
    if (visits91[i]==leaf) l=i;
    if (visits91[i]==other) o=i;
  end
  if (visits91.size()!=4 || r<0 || b<0 || l<0 || o<0) return 0;
  return topdown ? r<b && b<l && r<o : l<b && b<r && o<r;
endfunction
initial begin
  automatic component91 root=new("phase_root91",null);
  automatic component91 branch=new("branch",root);
  automatic component91 leaf=new("leaf",branch);
  automatic component91 other=new("other",root);
  automatic component91 outside=new("outside91",null);
  automatic down91 down=new();
  automatic up91 up=new();
  automatic uvm_phase first=new("first91",UVM_PHASE_SCHEDULE);
  automatic uvm_phase second=new("second91",UVM_PHASE_SCHEDULE);
  uvm_phase node_down,node_up,peer_down;
  uvm_domain owner;
  owner=root.get_domain();
  if (owner==null) $fatal(1,"phase91 missing component domain");
  first.add(down);
  first.add(up);
  second.add(down);
  second.add(up);
  node_down=MODE==0 ? first.find(down) : second.find(down);
  node_up=MODE==0 ? first.find(up) : second.find(up);
  peer_down=MODE==0 ? second.find(down) : first.find(down);
  if (node_down==null || node_up==null || peer_down==null) $fatal(1,"phase91 missing nodes");
  owner.add(first);
  owner.add(second);
  $display("UT: phase_types91 %s imp %0d node %0d schedule %0d domain %0d",CASE_NAME,
    down.get_phase_type()==UVM_PHASE_IMP && up.get_phase_type()==UVM_PHASE_IMP,
    node_down.get_phase_type()==UVM_PHASE_NODE && node_up.get_phase_type()==UVM_PHASE_NODE,
    first.get_phase_type()==UVM_PHASE_SCHEDULE && second.get_phase_type()==UVM_PHASE_SCHEDULE,
    owner.get_phase_type()==UVM_PHASE_DOMAIN);
  $display("UT: phase_types91 local_nodes %0d owner %0d",node_down!=peer_down &&
    node_down.get_parent()==(MODE==0 ? first : second) && peer_down.get_parent()==(MODE==0 ? second : first),
    node_down.get_domain()==owner && peer_down.get_domain()==owner);
  expected_node91=node_down;
  visits91.delete();
  down.traverse(root,node_down,UVM_PHASE_EXECUTING);
  $display("UT: phase_types91 topdown %0d node_context %0d",ordered91(root,branch,leaf,other,1),node_matches91);
  expected_node91=node_up;
  visits91.delete();
  up.traverse(root,node_up,UVM_PHASE_EXECUTING);
  $display("UT: phase_types91 bottomup %0d node_context %0d",ordered91(root,branch,leaf,other,0),node_matches91);
  $finish;
end
