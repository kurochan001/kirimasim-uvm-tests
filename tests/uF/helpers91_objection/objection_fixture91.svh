uvm_objection_event events91[3];
bit event_returned91[3];
time all_return91;
class token91 extends uvm_object;
  function new(string name); super.new(name); endfunction
endclass
class objection91 extends uvm_objection;
  bit raised_done=0,dropped_done=0,all_done=0;
  time all_completed;
  function new(string name); super.new(name); endfunction
  virtual function void raised(uvm_object obj,uvm_object source_obj,string description,int count);
    super.raised(obj,source_obj,description,count);
    if (obj==source_obj) raised_done=1;
  endfunction
  virtual function void dropped(uvm_object obj,uvm_object source_obj,string description,int count);
    super.dropped(obj,source_obj,description,count);
    if (obj==source_obj) dropped_done=1;
  endfunction
  virtual task all_dropped(uvm_object obj,uvm_object source_obj,string description,int count);
    if (obj==source_obj) begin #2; all_done=1; all_completed=$time; end
    super.all_dropped(obj,source_obj,description,count);
  endtask
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  virtual task run_phase(uvm_phase phase);
    automatic objection91 selected=new("selected91");
    automatic objection91 peer=new("peer91");
    automatic token91 first=new("first91");
    automatic token91 second=new("second91");
    uvm_object source,other;
    int count;
    phase.raise_objection(this); source=MODE==0 ? first : second; other=MODE==0 ? second : first;
    count=MODE==0 ? 2 : 3; selected.set_drain_time(source,0);
    events91='{UVM_RAISED,UVM_DROPPED,UVM_ALL_DROPPED};
    fork
      begin selected.wait_for(events91[0],source); event_returned91[0]=1; end
      begin selected.wait_for(events91[1],source); event_returned91[1]=1; end
      begin selected.wait_for(events91[2],source); event_returned91[2]=1; all_return91=$time; end
    join_none
    #1; selected.raise_objection(source,"raise91",count);
    #1;
    $display("UT: objection_events91 %s raised %0d callback %0d others_wait %0d",CASE_NAME,
      event_returned91[0],selected.raised_done,!event_returned91[1] && !event_returned91[2]);
    selected.drop_objection(source,"partial91",1);
    #1;
    $display("UT: objection_events91 dropped %0d callback %0d all_wait %0d remaining %0d",
      event_returned91[1],selected.dropped_done,!event_returned91[2],selected.get_objection_total(source)==count-1);
    selected.drop_objection(source,"last91",count-1);
    wait(event_returned91[0] && event_returned91[1] && event_returned91[2]);
    $display("UT: objection_events91 all %0d callback %0d after_callback %0d zero %0d peer %0d",
      event_returned91[2],selected.all_done,all_return91>=selected.all_completed,
      selected.get_objection_total(source)==0,selected.get_objection_total(other)==0 &&
      peer.get_objection_total(source)==0 && !peer.raised_done && !peer.dropped_done && !peer.all_done);
    phase.drop_objection(this);
  endtask
endclass
initial run_test("t");
