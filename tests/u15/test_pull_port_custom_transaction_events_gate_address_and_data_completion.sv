/*
:name: test_pull_port_custom_transaction_events_gate_address_and_data_completion
:description: pull port custom transaction events gate address and data completion
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.2.1 15.2.1.2.10 15.2.1.2.1 15.2.1.2.3 14.2.6.3 5.4.2.13 10.1.1.2.2 10.1.1.2.4 10.3.2.3 10.7.2.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pull_port_custom_transaction_events_gate_address_and_data_completion.expected
*/
// What it checks:
// 1. A transaction pool can carry a custom intermediate driver notification.
// 2. Separate custom transaction events can gate successive modeled execution
//    stages.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.2.1 (UVM-SEQUENCER-AUDIT-CUSTOM-ADDRESS) gives rule 1
//    above. Setup: With automatic marks disabled, create original
//    address59/data59 pool entries and trigger them at separate positive times
//    after the early acknowledgement. Expected: After item_done the producer
//    waits; triggering address59 releases only its first gate.
// 2. 1800.2-2020 15.2.1 (UVM-SEQUENCER-AUDIT-CUSTOM-DATA) gives rule 2 above.
//    Setup: With automatic marks disabled, create original address59/data59
//    pool entries and trigger them at separate positive times after the early
//    acknowledgement. Expected: A distinct data59 trigger completes the
//    producer after the address stage; no automatic begin/end callback occurs.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe the named transaction-pool events through standard typed callbacks.
// Creating observers does not certify initial event-pool membership. No record
// handle value, database format, callback payload or sibling order is assumed.
module test_pull_port_custom_transaction_events_gate_address_and_data_completion;
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
      sent.get_event_pool().get("address59").wait_trigger(); address_seen=1;
      sent.get_event_pool().get("data59").wait_trigger();
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
      client.port.disable_auto_item_recording();
      address_event=worker.sent.get_event_pool().get("address59");
      data_event=worker.sent.get_event_pool().get("data59");
      #2;
      fork worker.start(sequencer); join_none
      client.port.get_next_item(request);
      #2; client.port.item_done(); #1;
      $display("UT: custom released %0d address_pending %0d data_pending %0d identity %0d",
        worker.released,!worker.address_seen,!worker.completed,request==worker.sent);
      address_event.trigger(); #1;
      $display("UT: custom address_seen %0d data_pending %0d",
        worker.address_seen,!worker.completed);
      data_event.trigger(); #1;
      $display("UT: custom completed %0d distinct_events %0d no_automatic_marks %0d",
        worker.completed,address_event!=data_event,begin_probe.calls==0 && end_probe.calls==0);
      callbacks_t::delete(began,begin_probe); callbacks_t::delete(ended,end_probe);
      disable fork; sequencer.stop_sequences();
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1,"transaction event watchdog expired"); end
endmodule
