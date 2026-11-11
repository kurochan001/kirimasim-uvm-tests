uvm_printer expected_printer91;
class printer91 extends uvm_printer;
  int emits=0;
  virtual function string emit();
    emits++;
    return "TOPOLOGY91\n";
  endfunction
  function void prepare();
    emits=0;
    flush();
    set_max_depth(-1);
    set_recursion_policy(UVM_DEEP);
  endfunction
endclass
class actor91 extends uvm_component;
  int visits=0;
  bit wrong_policy=0;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  virtual function void do_print(uvm_printer printer);
    visits++;
    wrong_policy |= printer!=expected_printer91;
    super.do_print(printer);
  endfunction
endclass
initial begin
  automatic actor91 top_a=new("top_a91",null);
  automatic actor91 branch_a=new("branch",top_a);
  automatic actor91 leaf_a=new("leaf",branch_a);
  automatic actor91 top_b=new("top_b91",null);
  automatic actor91 leaf_b=new("leaf",top_b);
  automatic printer91 first=new();
  automatic printer91 second=new();
  uvm_coreservice_t service;
  uvm_root root;
  uvm_printer previous;
  printer91 selected,unused;
  actor91 actors[5];
  bit all_visited,policies_match;
  service=uvm_coreservice_t::get();
  root=service.get_root();
  previous=service.get_default_printer();
  actors='{top_a,branch_a,leaf_a,top_b,leaf_b};
  for (int round=0;round<2;round++) begin
    selected=round==0 ? first : second;
    unused=round==0 ? second : first;
    first.prepare();
    second.prepare();
    expected_printer91=selected;
    foreach (actors[i]) begin
      actors[i].visits=0;
      actors[i].wrong_policy=0;
    end
    service.set_default_printer(MODE==0 ? unused : selected);
    if (MODE==0) root.print_topology(selected);
    else if (MODE==1) root.print_topology();
    else root.print_topology(null);
    all_visited=1;
    policies_match=1;
    foreach (actors[i]) begin
      all_visited &= actors[i].visits>0;
      policies_match &= !actors[i].wrong_policy;
    end
    $display("UT: topology91 %s round %0d visited %0d policy %0d selected_emit %0d unused %0d",
      CASE_NAME,round,all_visited,policies_match,selected.emits>0,unused.emits==0);
  end
  service.set_default_printer(previous);
  $display("UT: topology91 restored %0d hierarchy %0d",service.get_default_printer()==previous,
    leaf_a.get_parent()==branch_a && branch_a.get_parent()==top_a && leaf_b.get_parent()==top_b);
  $finish;
end
