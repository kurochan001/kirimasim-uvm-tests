int observed89[$];
class callback89 extends uvm_callback;
  `uvm_object_utils(callback89)
  int identity;
  function new(string name="callback89",int id=0);
    super.new(name);
    identity=id;
    void'(callback_mode(1));
  endfunction
  virtual function void hit();
    observed89.push_back(identity);
  endfunction
endclass
class agent89 extends uvm_component;
  `uvm_component_utils(agent89)
  `uvm_register_cb(agent89,callback89)
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  function void fire(); `uvm_do_callbacks(agent89,callback89,hit()) endfunction
endclass
typedef uvm_callbacks#(agent89,callback89) pool89;
initial begin
  automatic agent89 target=new("target89",null);
  automatic agent89 peer=new("peer89",null);
  callback89 callbacks[5];
  uvm_apprepend ordering;
  int before_peer;
  bit peer_ok;
  peer_ok=1;
  for (int i=0;i<5;i++) begin
    callbacks[i]=new($sformatf("callback89_%0d",i),10+i);
    ordering=(i+MODE)%2==0 ? UVM_APPEND : UVM_PREPEND;
    pool89::add(target,callbacks[i],ordering);
    observed89.delete();
    target.fire();
    $write("UT: app89 %s step %0d",CASE_NAME,i);
    foreach (observed89[j]) $write(" %0d",observed89[j]);
    $write("\n");
    before_peer=observed89.size();
    peer.fire();
    peer_ok &= observed89.size()==before_peer;
  end
  $display("UT: app89 peer %0d literals %0d",peer_ok,UVM_APPEND!=UVM_PREPEND);
  $finish;
end
