// Original callbacks expose per-object order and METHOD argument propagation.
// No target traversal order, private queue, factory type or exact log is used.
`include "uvm_macros.svh"
uvm_object active_owner102;
int active_token102;
class callback102 extends uvm_callback;
  string tag102;
  int kind102,calls102;
  bit args_ok102;
  function new(string tag,int kind);
    super.new(tag);tag102=tag;kind102=kind;calls102=0;args_ok102=1;
    void'(callback_mode(1));
  endfunction
  virtual function void hook102(input uvm_object who,input int token,
                               ref int value,ref string trace);
    calls102++;args_ok102 &= who==active_owner102 && token==active_token102;
    case(kind102)
      0:value=2*value+3;
      1:value=3*value+7;
      2:value=value+11;
    endcase
    trace={trace,tag102};
  endfunction
endclass
class container102 extends uvm_component;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
endclass
class agent102 extends uvm_component;
  `uvm_register_cb(agent102,callback102)
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void fire102(int token,ref int value,ref string trace);
    `uvm_do_callbacks(agent102,callback102,hook102(this,token,value,trace))
  endfunction
endclass
typedef uvm_callbacks#(agent102,callback102) pool102;
container102 root102,branches102[2],outside102;
agent102 nodes102[4];
callback102 first102,shared102,last102;
function automatic void external102(agent102 obj,int token,ref int value,ref string trace);
  `uvm_do_obj_callbacks(agent102,callback102,obj,hook102(obj,token,value,trace))
endfunction
function automatic void show102(int stage);
  for(int i=0;i<4;i++) begin
    int value;
    string trace;
    value=stage*32+i+1;trace="";active_owner102=nodes102[i];active_token102=stage*10+i;
    if(SCENARIO102%2==0) nodes102[i].fire102(active_token102,value,trace);
    else external102(nodes102[i],active_token102,value,trace);
    $display("UT: named102 %0d %0d stage %0d node %0d trace %s value %0d args %0d",
      SCENARIO102,VARIANT102,stage,i,trace,value,
      first102.args_ok102 && shared102.args_ok102 && last102.args_ok102);
  end
endfunction
initial begin
  string exact_name;
  root102=new("root102",null);outside102=new("outside102",null);
  branches102[0]=new("left102",root102);branches102[1]=new("right102",root102);
  for(int j=0;j<4;j++) begin
    automatic int i=VARIANT102==0?j:3-j;
    if(i<2) nodes102[i]=new("slot",branches102[i]);
    else if(i==2) nodes102[i]=new("Slot",branches102[0]);
    else nodes102[i]=new("slot",outside102);
  end
  first102=new("A",0);shared102=new("S",1);last102=new("Z",2);
  for(int i=0;i<4;i++) begin pool102::add(nodes102[i],first102);pool102::add(nodes102[i],last102);end
  pool102::add(nodes102[3],shared102);show102(0);
  exact_name=nodes102[VARIANT102].get_full_name();
  case(SCENARIO102)
    0:pool102::add_by_name(exact_name,shared102,root102);
    1:pool102::add_by_name("*.slot",shared102,root102,UVM_PREPEND);
    2:pool102::add_by_name("*.slot",shared102,root102,UVM_APPEND);
    3:pool102::add_by_name("*.slot",shared102,branches102[VARIANT102],UVM_PREPEND);
  endcase
  show102(1);void'(shared102.callback_mode(0));show102(2);
  if(SCENARIO102<2) pool102::delete_by_name(exact_name,shared102,root102);
  else if(SCENARIO102==2) pool102::delete_by_name("*.slot",shared102,root102);
  else pool102::delete_by_name("*.slot",shared102,branches102[VARIANT102]);
  show102(3);void'(shared102.callback_mode(1));show102(4);
  case(SCENARIO102)
    0:pool102::add_by_name(exact_name,shared102,root102,UVM_PREPEND);
    1:pool102::add_by_name(exact_name,shared102,root102,UVM_APPEND);
    2:pool102::add_by_name("*.slot",shared102,branches102[VARIANT102],UVM_PREPEND);
    3:pool102::add_by_name("*.slot",shared102,root102,UVM_APPEND);
  endcase
  show102(5);show102(6);
  $display("UT: named102 %0d %0d final calls %0d %0d %0d enabled %0d",
    SCENARIO102,VARIANT102,first102.calls102,last102.calls102,shared102.calls102,
    shared102.is_enabled());
  $finish;
end
