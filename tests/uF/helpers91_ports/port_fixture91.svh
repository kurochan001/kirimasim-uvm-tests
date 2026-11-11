typedef uvm_port_base#(uvm_tlm_if_base#(int,int)) port_view91;
class role91 extends port_view91;
  function new(string name,uvm_component parent,uvm_port_type_e selected);
    super.new(name,parent,selected,0,1);
  endfunction
  virtual function void get_connected_to(ref port_view91 list[string]);
    list.delete();
  endfunction
  virtual function void get_provided_to(ref port_view91 list[string]);
    list.delete();
  endfunction
endclass
class collector91 extends uvm_component;
  uvm_analysis_imp#(int,collector91) imp;
  int values[$];
  function new(string name,uvm_component parent);
    super.new(name,parent);
    imp=new("imp",this);
  endfunction
  function void write(int value);
    values.push_back(value);
  endfunction
endclass
class bridge91 extends uvm_component;
  uvm_analysis_export#(int) exp;
  collector91 worker;
  function new(string name,uvm_component parent);
    super.new(name,parent);
    exp=new("exp",this);
    worker=new("worker",this);
  endfunction
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    exp.connect(worker.imp);
  endfunction
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  uvm_analysis_port#(int) source_port;
  bridge91 left,right,selected,peer;
  role91 roles[3];
  uvm_port_type_e kinds[3];
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    source_port=new("source_port",this);
    left=new("left",this);
    right=new("right",this);
    kinds='{UVM_PORT,UVM_EXPORT,UVM_IMPLEMENTATION};
    for (int i=0;i<3;i++) roles[i]=new($sformatf("role_%0d",i),this,kinds[i]);
    selected=MODE==0 ? left : right;
    peer=MODE==0 ? right : left;
  endfunction
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    source_port.connect(selected.exp);
  endfunction
  virtual task run_phase(uvm_phase phase);
    int first,second;
    phase.raise_objection(this);
    first=MODE==0 ? 23 : 467;
    second=MODE==0 ? -17 : -39;
    $display("UT: ports91 %s named_roles %0d real_roles %0d",CASE_NAME,
      roles[0].is_port() && !roles[0].is_export() && !roles[0].is_imp() &&
      roles[1].is_export() && !roles[1].is_port() && !roles[1].is_imp() &&
      roles[2].is_imp() && !roles[2].is_port() && !roles[2].is_export(),
      source_port.is_port() && selected.exp.is_export() && selected.worker.imp.is_imp());
    source_port.write(first);
    source_port.write(second);
    $display("UT: ports91 forwarded %0d peer %0d resolved %0d",
      selected.worker.values.size()==2 && selected.worker.values[0]==first &&
      selected.worker.values[1]==second,peer.worker.values.size()==0,
      source_port.size()==1 && selected.exp.size()==1);
    phase.drop_objection(this);
  endtask
endclass
initial run_test("t");
