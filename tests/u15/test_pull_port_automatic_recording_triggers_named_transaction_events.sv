/*
:name: test_pull_port_automatic_recording_triggers_named_transaction_events
:description: pull port automatic recording triggers named transaction events
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.2.1 15.3.2.22 15.2.1.2.1 15.2.1.2.3 5.4.2.4 5.4.2.6 5.4.2.13 5.4.2.16 10.2.2.3 10.7.2.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pull_port_automatic_recording_triggers_named_transaction_events.expected
*/
// What it checks:
// 1. A pull-port get_next_item automatically notifies the request transaction
//    begin event.
// 2. A pull-port item_done automatically notifies the transaction end event.
// 3. The begin timestamp exposes the selected automatic transaction mark.
// 4. The end timestamp exposes the selected delayed automatic transaction
//    mark.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.2.1 (UVM-SEQUENCER-AUDIT-AUTOMATIC-BEGIN) gives rule 1
//    above. Setup: Use a real connected typed pull port and sequencer, an
//    original producer item, named begin/end observers and positive delays
//    before request and acknowledgement. Expected: The exact producer item is
//    received, begin has one callback and end remains pending.
// 2. 1800.2-2020 15.2.1 (UVM-SEQUENCER-AUDIT-AUTOMATIC-END) gives rule 2
//    above. Setup: Use a real connected typed pull port and sequencer, an
//    original producer item, named begin/end observers and positive delays
//    before request and acknowledgement. Expected: After the delayed
//    acknowledgement the producer is released and end has one callback.
// 3. 1800.2-2020 5.4.2.16 (UVM-SEQUENCER-AUDIT-AUTOMATIC-BEGIN-TIME) gives
//    rule 3 above. Setup: Use a real connected typed pull port and sequencer,
//    an original producer item, named begin/end observers and positive delays
//    before request and acknowledgement. Expected: The transaction begin
//    timestamp and named-event callback time equal the get-next return time.
// 4. 1800.2-2020 5.4.2.16 (UVM-SEQUENCER-AUDIT-AUTOMATIC-END-TIME) gives rule
//    4 above. Setup: Use a real connected typed pull port and sequencer, an
//    original producer item, named begin/end observers and positive delays
//    before request and acknowledgement. Expected: The transaction end
//    timestamp and callback time equal the later item_done call time.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe the named transaction-pool events through standard typed callbacks.
// Creating observers does not certify initial event-pool membership. No record
// handle value, database format, callback payload or sibling order is assumed.
module test_pull_port_automatic_recording_triggers_named_transaction_events;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef uvm_event#(uvm_object) event_t;
  typedef uvm_event_callback#(uvm_object) callback_t;
  typedef uvm_callbacks#(event_t,callback_t) callbacks_t;
  class watch extends callback_t;
    event_t selected;
    int calls=0;
    time marked=0;
    bit identity=1;
    function new(); super.new("watch"); endfunction
    virtual function void post_trigger(event_t e,uvm_object data);
      calls++; marked=$time; identity &= e==selected;
    endfunction
  endclass
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class producer extends uvm_sequence#(packet);
    packet sent;
    bit released=0, completed=0, address_seen=0;
    function new(); super.new("producer"); sent=new("sent"); endfunction
    virtual task body();
      start_item(sent); finish_item(sent); released=1;

      completed=1;
    endtask
  endclass
  class endpoint extends uvm_component;
    uvm_seq_item_pull_port#(packet) port;
    function new(string name,uvm_component parent);
      super.new(name,parent); port=new("port",this);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    endpoint client;
    producer worker;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer=new("sequencer",this); client=new("client",this); worker=new();
    endfunction
    function void connect_phase(uvm_phase phase);
      client.port.connect(sequencer.seq_item_export);
    endfunction
    virtual task run_phase(uvm_phase phase);
      packet request;
      event_t began,ended,address_event,data_event;
      watch begin_probe,end_probe;
      time initial_begin,initial_end,begin_mark,end_mark;
      int ignored_handle;
      phase.raise_objection(this);
      began=worker.sent.get_event_pool().get("begin");
      ended=worker.sent.get_event_pool().get("end");
      begin_probe=new(); end_probe=new();
      begin_probe.selected=began; end_probe.selected=ended;
      callbacks_t::add(began,begin_probe); callbacks_t::add(ended,end_probe);
      initial_begin=worker.sent.get_begin_time(); initial_end=worker.sent.get_end_time();

      #2;
      fork worker.start(sequencer); join_none
      client.port.get_next_item(request);
      begin_mark=$time;
      $display("UT: automatic_begin identity %0d begin_once %0d end_pending %0d time %0d",
        request==worker.sent,begin_probe.calls==1,end_probe.calls==0,
        worker.sent.get_begin_time()==begin_mark && begin_probe.marked==begin_mark);
      #3; end_mark=$time; client.port.item_done();
      #1;
      $display("UT: automatic_end released %0d end_once %0d time %0d callbacks %0d",
        worker.released,end_probe.calls==1,
        worker.sent.get_end_time()==end_mark && end_probe.marked==end_mark,
        begin_probe.identity && end_probe.identity);
      callbacks_t::delete(began,begin_probe); callbacks_t::delete(ended,end_probe);
      disable fork; sequencer.stop_sequences();
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1,"transaction event watchdog expired"); end
endmodule
