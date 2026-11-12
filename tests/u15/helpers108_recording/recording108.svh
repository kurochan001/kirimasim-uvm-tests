// Original connected traffic and public transaction-pool observers.
typedef uvm_event#(uvm_object) event108;
typedef uvm_event_callback#(uvm_object) callback108;
typedef uvm_callbacks#(event108,callback108) callbacks108;
class probe108 extends callback108;
  event108 selected;
  int calls=0;
  time marked=0;
  bit identity=1;
  function new();
    super.new("probe");
  endfunction
  virtual function void post_trigger(event108 e, uvm_object data);
    calls++;
    marked=$time;
    identity &= e==selected;
  endfunction
endclass
class packet108 extends uvm_sequence_item;
  `uvm_object_utils(packet108)
  function new(string name="packet");
    super.new(name);
  endfunction
endclass
class observer108;
  packet108 item;
  event108 began, ended;
  probe108 begin_probe, end_probe;
  time initial_begin, initial_end, driver_begin, driver_end;
  bit entered=0, completed=0, same_item=0, release_gate=0;
  function new(packet108 target);
    item=target;
    began=item.get_event_pool().get("begin");
    ended=item.get_event_pool().get("end");
    begin_probe=new();
    end_probe=new();
    begin_probe.selected=began;
    end_probe.selected=ended;
    callbacks108::add(began,begin_probe);
    callbacks108::add(ended,end_probe);
    initial_begin=item.get_begin_time();
    initial_end=item.get_end_time();
  endfunction
  function void detach();
    callbacks108::delete(began,begin_probe);
    callbacks108::delete(ended,end_probe);
  endfunction
endclass
class producer108 extends uvm_sequence#(packet108);
  packet108 item;
  bit done=0;
  function new(string name="producer");
    super.new(name);
    item=new("item");
  endfunction
  virtual task body();
    start_item(item);
    finish_item(item);
    done=1;
  endtask
endclass

task automatic serve108(input uvm_component owner, input packet108 item,
                        input observer108 obs, input bit manual_marks);
  int ignored_handle;
  obs.same_item=item==obs.item;
  obs.entered=1;
  obs.driver_begin=$time;
  if (manual_marks) ignored_handle=owner.begin_tr(item);
  #3;
  wait(obs.release_gate);
  obs.driver_end=$time;
  if (manual_marks) owner.end_tr(item);
  obs.completed=1;
endtask
class pull_driver108 extends uvm_component;
  uvm_seq_item_pull_port#(packet108) port;
  observer108 obs;
  bit open_gate=0, manual_marks=0;
  function new(string name,uvm_component parent);
    super.new(name,parent);
    port=new("port",this);
  endfunction
  virtual task run_phase(uvm_phase phase);
    packet108 item;
    wait(open_gate);
    port.get_next_item(item);
    serve108(this,item,obs,manual_marks);
    port.item_done();
  endtask
endclass
class push_driver108 extends uvm_push_driver#(packet108);
  observer108 obs;
  bit manual_marks=0;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  virtual task put(packet108 item);
    serve108(this,item,obs,manual_marks);
  endtask
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  uvm_sequencer_base selected,peer;
  uvm_sequencer#(packet108) selected_pull,peer_pull;
  uvm_push_sequencer#(packet108) selected_push,peer_push;
  pull_driver108 selected_pull_driver,peer_pull_driver;
  push_driver108 selected_push_driver,peer_push_driver;
  producer108 selected_worker,peer_worker;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    selected_worker=new("selected_worker");
    peer_worker=new("peer_worker");
    if (PUSH108) begin
      selected_push=new("selected",this);
      peer_push=new("peer",this);
      selected=selected_push;
      peer=peer_push;
      selected_push_driver=new("selected_driver",this);
      peer_push_driver=new("peer_driver",this);
    end else begin
      selected_pull=new("selected",this);
      peer_pull=new("peer",this);
      selected=selected_pull;
      peer=peer_pull;
      selected_pull_driver=new("selected_driver",this);
      peer_pull_driver=new("peer_driver",this);
    end
  endfunction
  function void connect_phase(uvm_phase phase);
    if (PUSH108) begin
      selected_push.req_port.connect(selected_push_driver.req_export);
      peer_push.req_port.connect(peer_push_driver.req_export);
    end else begin
      selected_pull_driver.port.connect(selected_pull.seq_item_export);
      peer_pull_driver.port.connect(peer_pull.seq_item_export);
    end
  endfunction
  virtual task run_phase(uvm_phase phase);
    observer108 chosen,other;
    bit begin_time_ok,end_time_ok;
    phase.raise_objection(this);
    chosen=new(selected_worker.item);
    other=new(peer_worker.item);
    selected.disable_auto_item_recording();
    selected.disable_auto_item_recording();
    if (PUSH108) begin
      selected_push_driver.obs=chosen;
      peer_push_driver.obs=other;
      selected_push_driver.manual_marks=MANUAL108;
    end else begin
      selected_pull_driver.obs=chosen;
      peer_pull_driver.obs=other;
      selected_pull_driver.manual_marks=MANUAL108;
    end
    $display("UT: initial selected_begin %0d selected_end %0d distinct_items %0d",
             chosen.begin_probe.calls,chosen.end_probe.calls,
             selected_worker.item!=peer_worker.item);
    #2;
    if (!PUSH108) begin
      selected_pull_driver.open_gate=1;
      peer_pull_driver.open_gate=1;
    end
    fork
      selected_worker.start(selected);
      peer_worker.start(peer);
    join_none
    wait(chosen.entered && other.entered);
    #1;
    $display("UT: held original_items %0d both_pending %0d",
             chosen.same_item && other.same_item,
             !chosen.completed && !other.completed && !selected_worker.done && !peer_worker.done);
    if (MANUAL108) begin_time_ok=chosen.item.get_begin_time()==chosen.driver_begin &&
                                chosen.begin_probe.marked==chosen.driver_begin;
    else begin_time_ok=chosen.item.get_begin_time()==chosen.initial_begin;
    $display("UT: selected_begin calls %0d end_pending %0d time %0d identity %0d",
             chosen.begin_probe.calls,chosen.end_probe.calls==0,
             begin_time_ok,chosen.begin_probe.identity);
    // Keep the held observation independent of which driver entered first.
    chosen.release_gate=1;
    other.release_gate=1;
    wait(chosen.completed && other.completed && selected_worker.done && peer_worker.done);
    #1;
    if (MANUAL108) end_time_ok=chosen.item.get_end_time()==chosen.driver_end &&
                              chosen.end_probe.marked==chosen.driver_end;
    else end_time_ok=chosen.item.get_end_time()==chosen.initial_end;
    $display("UT: completion selected %0d peer %0d original_items %0d",
             selected_worker.done,peer_worker.done,chosen.same_item && other.same_item);
    $display("UT: selected_end calls %0d time %0d identity %0d",
             chosen.end_probe.calls,end_time_ok,chosen.end_probe.identity);
    $display("DIAG108: peer begin %0d end %0d",other.begin_probe.calls,other.end_probe.calls);
    chosen.detach();
    other.detach();
    selected.stop_sequences();
    peer.stop_sequences();
    phase.drop_objection(this);
  endtask
endclass
