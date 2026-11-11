// Original trees, visitors and interface bodies; no copied traversal algorithm.
class node69 extends uvm_object;
  node69 children[$];
  function new(string name);
    super.new(name);
  endfunction
endclass
class proxy69 extends uvm_structure_proxy#(node69);
  int calls=0;
  function new();
    super.new("proxy69");
  endfunction
  virtual function void get_immediate_children(node69 s,ref node69 children[$]);
    calls++;
    children=s.children;
  endfunction
endclass
class visitor69 extends uvm_visitor#(node69);
  node69 visited[$];
  int begins=0,ends=0,before_count=-1,after_count=-1;
  function new();
    super.new("visitor69");
  endfunction
  virtual function void begin_v();
    begins++;
    before_count=visited.size();
  endfunction
  virtual function void end_v();
    ends++;
    after_count=visited.size();
  endfunction
  virtual function void visit(node69 node);
    visited.push_back(node);
  endfunction
  function int position69(node69 node);
    foreach(visited[i])if(visited[i]==node)return i;
    return -1;
  endfunction
  function int count69(node69 node);
    int count;
    count=0;
    foreach(visited[i])if(visited[i]==node)count++;
    return count;
  endfunction
endclass
class quiet_visitor69 extends uvm_visitor#(node69);
  int calls=0;
  node69 last_node;
  function new();
    super.new("quiet69");
  endfunction
  virtual function void visit(node69 node);
    calls++;
    last_node=node;
  endfunction
endclass
class component69 extends uvm_component;
  function new(string name,uvm_component parent=null);
    super.new(name,parent);
  endfunction
endclass
class component_visitor69 extends uvm_visitor#();
  uvm_component visited[$];
  function new();
    super.new("component_visitor69");
  endfunction
  virtual function void visit(uvm_component node);
    visited.push_back(node);
  endfunction
endclass
class component_proxy69 extends uvm_structure_proxy#();
  function new();
    super.new("component_proxy69");
  endfunction
  virtual function void get_immediate_children(uvm_component s,
      ref uvm_component children[$]);
    uvm_component_proxy actual;
    actual=new();
    actual.get_immediate_children(s,children);
  endfunction
endclass
function automatic void traverse69(node69 s,visitor69 v,
    uvm_structure_proxy#(node69) p,bit invoke_begin_end);
  uvm_top_down_visitor_adapter#(node69,visitor69) actual;
  actual=new();
  actual.accept(s,v,p,invoke_begin_end);
endfunction
class complete_adapter69 extends uvm_visitor_adapter#(node69,visitor69);
  int calls=0;
  node69 last_s;
  visitor69 last_v;
  uvm_structure_proxy#(node69) last_p;
  bit last_flag;
  function new();
    super.new("complete69");
  endfunction
  virtual function void accept(node69 s,visitor69 v,uvm_structure_proxy#(node69) p,
      bit invoke_begin_end=1);
    calls++;
    last_s=s;
    last_v=v;
    last_p=p;
    last_flag=invoke_begin_end;
    traverse69(s,v,p,invoke_begin_end);
  endfunction
endclass
