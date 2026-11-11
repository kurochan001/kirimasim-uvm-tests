// Original static-iterator fixtures use public APIs and exact handle identities.
// The iterator integer representation and private callback queues are opaque.
`include "uvm_macros.svh"
class base103 extends uvm_callback;
  function new(string name);
    super.new(name);
  endfunction
endclass
class leaf103 extends base103;
  function new(string name);
    super.new(name);
  endfunction
endclass
class foreign103 extends uvm_callback;
  function new(string name);
    super.new(name);
  endfunction
endclass
class agent103 extends uvm_component;
  `uvm_register_cb(agent103,base103)
  `uvm_register_cb(agent103,foreign103)
  function new(string name);
    super.new(name,null);
  endfunction
endclass
typedef uvm_callbacks#(agent103,base103) pool103;
typedef uvm_callbacks#(agent103,foreign103) foreign_pool103;
agent103 context103,peer103,selected103;
base103 a103[4],added103[5],outside103;
foreign103 b103[3];
leaf103 leaf_value103;
function automatic base103 endpoint103(ref int position);
  if(MODE103%2==0)return pool103::get_first(position,selected103);
  return pool103::get_last(position,selected103);
endfunction
function automatic base103 step103(ref int position);
  if(MODE103%2==0)return pool103::get_next(position,selected103);
  return pool103::get_prev(position,selected103);
endfunction
function automatic void emit103(string label,base103 got,base103 expected_value);
  $display("UT: iterator103 %0d %0d %s selected %0d null %0d",
    MODE103,TYPEWIDE103,label,got==expected_value,got==null);
endfunction
function automatic void install103();
  for(int i=0;i<4;i++)begin
    if(i==3)begin
      leaf_value103=new("leaf");
      a103[i]=leaf_value103;
    end
    else a103[i]=new($sformatf("a%0d",i));
    void'(a103[i].callback_mode(MODE103>=2 && (i==1 || i==2)));
    pool103::add(selected103,a103[i]);
    if(i<3)begin
      b103[i]=new($sformatf("b%0d",i));
      void'(b103[i].callback_mode(1));
      foreign_pool103::add(selected103,b103[i]);
    end
  end
endfunction
initial begin
  int position;
  base103 got;
  context103=new("context103");
  peer103=new("peer103");
  selected103=TYPEWIDE103?null:context103;
  outside103=new("outside");
  void'(outside103.callback_mode(1));
  pool103::add(TYPEWIDE103?context103:peer103,outside103);
  position=0;
  got=endpoint103(position);
  emit103("empty_start",got,null);
  if(MODE103<2)begin
    install103();
    got=endpoint103(position);
    emit103("all_disabled",got,null);
    void'(a103[2].callback_mode(1));
    got=endpoint103(position);
    emit103("single_enabled",got,a103[2]);
    void'(a103[1].callback_mode(1));
    got=endpoint103(position);
    emit103("two_enabled",got,MODE103==0?a103[1]:a103[2]);
    void'(a103[1].callback_mode(0));
    void'(a103[2].callback_mode(0));
    got=endpoint103(position);
    emit103("disabled_again",got,null);
    void'(a103[0].callback_mode(1));
    void'(a103[3].callback_mode(1));
    got=endpoint103(position);
    emit103("enabled_edges",got,MODE103==0?a103[0]:a103[3]);
    for(int i=0;i<4;i++)pool103::delete(selected103,a103[i]);
    got=endpoint103(position);
    emit103("foreign_only",got,null);
  end else begin
    got=step103(position);
    emit103("empty_step",got,null);
    got=step103(position);
    emit103("empty_repeat",got,null);
    install103();
    // After exhaustion,10.7.2.4.3/.4 requires null until the endpoint reset.
    // Completed add calls do not replace that explicitly required reset.
    got=step103(position);
    emit103("after_empty_add",got,null);
    got=endpoint103(position);
    emit103("reset_initial",got,MODE103==2?a103[1]:a103[2]);
    got=step103(position);
    emit103("initial_step",got,MODE103==2?a103[2]:a103[1]);
    got=step103(position);
    emit103("initial_exhausted",got,null);
    got=step103(position);
    emit103("initial_repeat",got,null);
    for(int i=0;i<5;i++)begin
      added103[i]=new($sformatf("added%0d",i));
      void'(added103[i].callback_mode(1));
      pool103::add(selected103,added103[i]);
    end
    got=step103(position);
    emit103("after_exhausted_add",got,null);
    got=endpoint103(position);
    emit103("reset_grown",got,MODE103==2?a103[1]:added103[4]);
    for(int i=0;i<6;i++)begin
      base103 wanted;
      if(MODE103==2)wanted=i==0?a103[2]:added103[i-1];
      else wanted=i<4?added103[3-i]:(i==4?a103[2]:a103[1]);
      got=step103(position);
      emit103($sformatf("grown_step_%0d",i),got,wanted);
    end
    got=step103(position);
    emit103("grown_exhausted",got,null);
    got=step103(position);
    emit103("grown_repeat",got,null);
    for(int i=0;i<4;i++)pool103::delete(selected103,a103[i]);
    for(int i=0;i<5;i++)pool103::delete(selected103,added103[i]);
    got=endpoint103(position);
    emit103("foreign_only",got,null);
  end
  $finish;
end
