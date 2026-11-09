// Original in-memory backend; only named packet properties define the oracle.
class sink109;
  int selected_fields=0, peer_fields=0, streams=0, opens=0, closes=0, frees=0;
  bit selected_values=1, peer_values=1;
endclass
class recorder109 extends uvm_recorder;
  sink109 sink;
  function new(string name="recorder");
    super.new(name);
  endfunction
  protected virtual function void do_open(uvm_tr_stream stream,time open_time,string type_name);
    sink.opens++;
  endfunction
  protected virtual function void do_close(time close_time);
    sink.closes++;
  endfunction
  protected virtual function void do_free();
    sink.frees++;
  endfunction
  protected virtual function void do_record_field(string name,uvm_bitstream_t value,int size,
                                                 uvm_radix_enum radix); endfunction
  protected virtual function void do_record_field_int(string name,uvm_integral_t value,int size,
                                                     uvm_radix_enum radix);
    if (name=="selected109") begin
      sink.selected_fields++;
      sink.selected_values &= value[31:0]==41 && size==32 && radix==UVM_DEC;
    end
    if (name=="peer109") begin
      sink.peer_fields++;
      sink.peer_values &= value[31:0]==97 && size==32 && radix==UVM_DEC;
    end
  endfunction
  protected virtual function void do_record_field_real(string name,real value); endfunction
  protected virtual function void do_record_string(string name,string value); endfunction
  protected virtual function void do_record_time(string name,time value); endfunction
  protected virtual function void do_record_generic(string name,string value,string type_name); endfunction
endclass
class stream109 extends uvm_tr_stream;
  sink109 sink;
  function new(string name="stream");
    super.new(name);
  endfunction
  protected virtual function void do_open(uvm_tr_database db,string scope,string stream_type_name); endfunction
  protected virtual function void do_close(); endfunction
  protected virtual function void do_free(); endfunction
  protected virtual function uvm_recorder do_open_recorder(string name,time open_time,string type_name);
    automatic recorder109 result_value=new(name);
    result_value.sink=sink;
    return result_value;
  endfunction
endclass
class database109 extends uvm_tr_database;
  sink109 sink;
  function new(string name="db");
    super.new(name);
    sink=new();
  endfunction
  protected virtual function bit do_open_db();
    return 1;
  endfunction
  protected virtual function bit do_close_db();
    return 1;
  endfunction
  protected virtual function uvm_tr_stream do_open_stream(string name,string scope,string type_name);
    automatic stream109 result_value=new(name);
    result_value.sink=sink;
    sink.streams++;
    return result_value;
  endfunction
  protected virtual function void do_establish_link(uvm_link_base link); endfunction
endclass
class packet109 extends uvm_sequence_item;
  `uvm_object_utils(packet109)
  string lane;
  int unsigned payload=0;
  int records=0;
  function new(string name="packet");
    super.new(name);
  endfunction
  virtual function void do_record(uvm_recorder recorder);
    records++;
    if (recorder!=null) recorder.record_field_int(lane,payload,32,UVM_DEC);
  endfunction
endclass
class flight109;
  packet109 expected;
  bit entered=0, completed=0, same_item=0, release_gate=0;
endclass
class producer109 extends uvm_sequence#(packet109);
  packet109 item;
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
// No driver calls record, begin_tr, end_tr or a backend field hook.
task automatic serve109(input packet109 item,input flight109 flight);
  flight.same_item=item==flight.expected;
  flight.entered=1;
  #3;
  wait(flight.release_gate);
  flight.completed=1;
endtask
class pull_driver109 extends uvm_component;
  uvm_seq_item_pull_port#(packet109) port;
  flight109 flight;
  bit open_gate=0;
  function new(string name,uvm_component parent);
    super.new(name,parent);
    port=new("port",this);
  endfunction
  virtual task run_phase(uvm_phase phase);
    packet109 item;
    wait(open_gate);
    port.get_next_item(item);
    serve109(item,flight);
    port.item_done();
  endtask
endclass
class push_driver109 extends uvm_push_driver#(packet109);
  flight109 flight;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  virtual task put(packet109 t);
    serve109(t,flight);
  endtask
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  uvm_sequencer_base selected,peer;
  uvm_sequencer#(packet109) selected_pull,peer_pull;
  uvm_push_sequencer#(packet109) selected_push,peer_push;
  pull_driver109 selected_pull_driver,peer_pull_driver;
  push_driver109 selected_push_driver,peer_push_driver;
  producer109 selected_worker,peer_worker;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    selected_worker=new("selected_worker");
    peer_worker=new("peer_worker");
    selected_worker.item.lane="selected109";
    selected_worker.item.payload=41;
    peer_worker.item.lane="peer109";
    peer_worker.item.payload=97;
    if (PUSH109) begin
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
    if (PUSH109) begin
      selected_push.req_port.connect(selected_push_driver.req_export);
      peer_push.req_port.connect(peer_push_driver.req_export);
    end else begin
      selected_pull_driver.port.connect(selected_pull.seq_item_export);
      peer_pull_driver.port.connect(peer_pull.seq_item_export);
    end
  endfunction
  virtual task run_phase(uvm_phase phase);
    database109 db;
    uvm_coreservice_t service;
    uvm_tr_database previous;
    uvm_tr_stream selected_stream,peer_stream;
    flight109 chosen,other;
    bit opened;
    phase.raise_objection(this);
    db=new();
    opened=db.open_db();
    service=uvm_coreservice_t::get();
    previous=service.get_default_tr_database();
    service.set_default_tr_database(db);
    selected.set_tr_database(db);
    peer.set_tr_database(db);
    selected.set_recording_enabled(1);
    peer.set_recording_enabled(1);
    selected_stream=db.open_stream("selected_setup");
    peer_stream=db.open_stream("peer_setup");
    selected_worker.item.enable_recording(selected_stream);
    peer_worker.item.enable_recording(peer_stream);
    chosen=new();
    other=new();
    chosen.expected=selected_worker.item;
    other.expected=peer_worker.item;
    if (PUSH109) begin
      selected_push_driver.flight=chosen;
      peer_push_driver.flight=other;
    end else begin
      selected_pull_driver.flight=chosen;
      peer_pull_driver.flight=other;
    end
    $display("UT: setup database %0d component_recording %0d transaction_recording %0d fields_empty %0d",
             opened && selected.get_tr_database()==db && peer.get_tr_database()==db,
             selected.get_recording_enabled() && peer.get_recording_enabled(),
             selected_worker.item.is_recording_enabled() && peer_worker.item.is_recording_enabled(),
             db.sink.selected_fields==0 && db.sink.peer_fields==0);
    // Observe explicit setup before the separate suppression API.
    if (DISABLE109) selected.disable_auto_item_recording();
    #2;
    if (!PUSH109) begin
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
    chosen.release_gate=1;
    other.release_gate=1;
    wait(chosen.completed && other.completed && selected_worker.done && peer_worker.done);
    #1;
    $display("DIAG109: hooks %0d %0d fields %0d %0d streams %0d opens %0d closes %0d frees %0d",
             selected_worker.item.records,peer_worker.item.records,db.sink.selected_fields,
             db.sink.peer_fields,db.sink.streams,db.sink.opens,db.sink.closes,db.sink.frees);
    // Wait for positive property evidence without prescribing an issue/record timestamp.
    wait(db.sink.peer_fields>0);
    if (!DISABLE109) wait(db.sink.selected_fields>0);
    #1;
    $display("UT: automatic selected_hooks %0d selected_fields %0d peer_hooks %0d peer_fields %0d",
             selected_worker.item.records>0,db.sink.selected_fields>0,
             peer_worker.item.records>0,db.sink.peer_fields>0);
    $display("UT: properties selected %0d peer %0d",db.sink.selected_values,db.sink.peer_values);
    $display("UT: completion selected %0d peer %0d original_items %0d",
             selected_worker.done,peer_worker.done,chosen.same_item && other.same_item);
    selected.stop_sequences();
    peer.stop_sequences();
    service.set_default_tr_database(previous);
    phase.drop_objection(this);
  endtask
endclass
