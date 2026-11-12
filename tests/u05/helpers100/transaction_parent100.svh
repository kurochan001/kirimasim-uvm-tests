// Original in-memory observers; no external database or fixed handle numbering.
class recorder100 extends uvm_recorder;
  time opened_at;
  function new(string name);
    super.new(name);
  endfunction
  protected virtual function void do_open(uvm_tr_stream stream,time open_time,string type_name);
    opened_at=open_time;
  endfunction
  protected virtual function void do_close(time close_time);endfunction
  protected virtual function void do_free();endfunction
  protected virtual function void do_record_field(string name,uvm_bitstream_t value,int size,uvm_radix_enum radix);endfunction
  protected virtual function void do_record_field_int(string name,uvm_integral_t value,int size,uvm_radix_enum radix);endfunction
  protected virtual function void do_record_field_real(string name,real value);endfunction
  protected virtual function void do_record_string(string name,string value);endfunction
  protected virtual function void do_record_time(string name,time value);endfunction
  protected virtual function void do_record_generic(string name,string value,string type_name);endfunction
endclass
class stream100 extends uvm_tr_stream;
  recorder100 last;
  int opens=0;
  function new(string name);
    super.new(name);
  endfunction
  protected virtual function void do_open(uvm_tr_database db,string scope,string stream_type_name);endfunction
  protected virtual function void do_close();endfunction
  protected virtual function void do_free();endfunction
  protected virtual function uvm_recorder do_open_recorder(string name,time open_time,string type_name);
    last=new(name);
    opens++;
    return last;
  endfunction
endclass
class database100 extends uvm_tr_database;
  uvm_object lefts[$],rights[$];
  bit parent_child[$];
  function new();
    super.new("database100");
  endfunction
  protected virtual function bit do_open_db();
    return 1;
  endfunction
  protected virtual function bit do_close_db();
    return 1;
  endfunction
  protected virtual function uvm_tr_stream do_open_stream(string name,string scope,string type_name);
    stream100 value;
    value=new(name);
    return value;
  endfunction
  protected virtual function void do_establish_link(uvm_link_base link);
    uvm_parent_child_link pc;
    lefts.push_back(link.get_lhs());
    rights.push_back(link.get_rhs());
    parent_child.push_back($cast(pc,link));
  endfunction
  function bit relation_ok100(uvm_recorder child,uvm_recorder parent);
    bit seen,wrong;
    seen=0;
    wrong=0;
    // The standard requires a typed relation to the selected parent, but does
    // not assign parent/child to specific lhs/rhs slots or prescribe a count.
    foreach(lefts[i]) if(parent_child[i] && (lefts[i]==child || rights[i]==child)) begin
      if(parent!=null && ((lefts[i]==parent && rights[i]==child) ||
                         (rights[i]==parent && lefts[i]==child))) seen=1;
      else wrong=1;
    end
    return parent==null ? !wrong : seen && !wrong;
  endfunction
endclass
class parent100 extends uvm_transaction;
  function new(string name);
    super.new(name);
  endfunction
endclass
class transaction100 extends uvm_transaction;
  database100 db;
  stream100 stream;
  uvm_recorder expected_parent;
  int hooks=0;
  bit hook_order=1;
  function new(string name);
    super.new(name);
  endfunction
  protected virtual function void do_begin_tr();
    hooks++;
    hook_order &= stream.last!=null && stream.last.opened_at==get_begin_time();
    if(stream.last!=null) begin
      hook_order &= get_tr_handle()==stream.last.get_handle() && get_tr_handle()!=0;
      hook_order &= db.relation_ok100(stream.last,expected_parent);
    end
  endfunction
endclass
typedef uvm_event#(uvm_object) event100;
typedef uvm_event_callback#(uvm_object) callback100;
typedef uvm_callbacks#(event100,callback100) callbacks100;
class watch100 extends callback100;
  transaction100 subject;
  event100 selected;
  int calls=0;
  bit order_ok=1;
  function new();
    super.new("watch100");
  endfunction
  virtual function void post_trigger(event100 e,uvm_object data);
    calls++;
    order_ok &= e==selected && subject.hooks==calls && subject.hook_order;
  endfunction
endclass
database100 db100;
stream100 parent_streams100[2],child_streams100[2];
parent100 parents100[2];
transaction100 children100[2];
watch100 watches100[2];
int parent_handles100[2],child_handles100[2];
int selected100,peer100;
task automatic begin_child100(int i,int step);
  int parent_index,opened_before,hooks_before;
  time explicit_time;
  parent_index=(i+MODE100-2)%2;
  if(MODE100<2) children100[i].expected_parent=null;
  else children100[i].expected_parent=parent_streams100[parent_index].last;
  opened_before=child_streams100[i].opens;
  hooks_before=children100[i].hooks;
  explicit_time=step*6+5;
  if(MODE100==0) child_handles100[i]=children100[i].begin_tr();
  else if(MODE100==1) child_handles100[i]=children100[i].begin_tr(0,0);
  else child_handles100[i]=children100[i].begin_tr(explicit_time,parent_handles100[parent_index]);
  $display("UT: parent100 %0d %0d step %0d live_handle %0d same_time %0d opened_once %0d",
    MODE100,VARIANT100,step,
    child_handles100[i]!=0 && child_handles100[i]==children100[i].get_tr_handle() &&
      uvm_recorder::get_recorder_from_handle(child_handles100[i])==child_streams100[i].last,
    child_streams100[i].last!=null && child_streams100[i].last.opened_at==children100[i].get_begin_time(),
    child_streams100[i].opens==opened_before+1);
  $display("UT: parent100 %0d %0d step %0d relation %0d hook_order %0d event_order %0d peers %0d",
    MODE100,VARIANT100,step,
    db100.relation_ok100(child_streams100[i].last,children100[i].expected_parent),
    children100[i].hooks==hooks_before+1 && children100[i].hook_order,
    watches100[i].calls==children100[i].hooks && watches100[i].order_ok,
    parents100[0].get_tr_handle()==parent_handles100[0] && parents100[1].get_tr_handle()==parent_handles100[1]);
  if(MODE100>=2) $display("UT: parent100 %0d %0d step %0d explicit_time %0d",
    MODE100,VARIANT100,step,children100[i].get_begin_time()==explicit_time);
endtask
initial begin
  uvm_tr_stream raw;
  uvm_event_pool pool;
  db100=new();
  selected100=VARIANT100;
  peer100=1-VARIANT100;
  if(!db100.open_db()) $fatal(1,"original database did not open");
  for(int j=0;j<2;j++) begin
    automatic int i=VARIANT100==0?j:1-j;
    parents100[i]=new($sformatf("parent100_%0d",i));
    children100[i]=new($sformatf("child100_%0d",i));
    watches100[i]=new();
    raw=db100.open_stream($sformatf("parents100_%0d",i));
    if(!$cast(parent_streams100[i],raw)) $fatal(1,"parent stream missing");
    raw=db100.open_stream($sformatf("children100_%0d",i));
    if(!$cast(child_streams100[i],raw)) $fatal(1,"child stream missing");
    parents100[i].enable_recording(parent_streams100[i]);
    children100[i].enable_recording(child_streams100[i]);
    children100[i].db=db100;
    children100[i].stream=child_streams100[i];
    watches100[i].subject=children100[i];
    pool=children100[i].get_event_pool();
    watches100[i].selected=pool.get("begin");
    callbacks100::add(watches100[i].selected,watches100[i]);
  end
  #2;
  parent_handles100[0]=parents100[0].begin_tr(1);
  parent_handles100[1]=parents100[1].begin_tr(2);
  #18;
  begin_child100(selected100,1);
  #10;
  begin_child100(peer100,2);
  #5;
  children100[selected100].end_tr();
  #5;
  begin_child100(selected100,3);
  $display("UT: parent100 %0d %0d final independent %0d repeated %0d",
    MODE100,VARIANT100,
    child_handles100[selected100]!=child_handles100[peer100] &&
      children100[peer100].get_tr_handle()==child_handles100[peer100],
    children100[selected100].hooks==2 && watches100[selected100].calls==2 &&
      children100[peer100].hooks==1 && watches100[peer100].calls==1);
  $finish;
end
initial begin
  #200;
  $fatal(1,"transaction-parent watchdog expired");
end
