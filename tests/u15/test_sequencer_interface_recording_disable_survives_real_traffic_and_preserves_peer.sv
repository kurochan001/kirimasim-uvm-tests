/*
:name: test_sequencer_interface_recording_disable_survives_real_traffic_and_preserves_peer
:description: sequencer interface recording disable survives real traffic and preserves peer
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.2.1.2.10 15.2.1.2.11 15.3.2.22 15.2.1.2.1 15.2.1.2.3 15.5.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_interface_recording_disable_survives_real_traffic_and_preserves_peer.expected
*/
// What it checks:
// 1. Repeated interface recording disable remains effective across the
//    selected real request traffic.
// 2. The interface query reports selected enabled/disabled recording states
//    while an independent peer retains its state.
// 3. The base recording-disable API changes the selected sequencer state
//    without disabling an independent peer.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.2.1.2.10 (UVM-SQR-AUDIT-INTERFACE-RECORDING-DISABLE) gives
//    rule 1 above. Setup: Use the selected original fixture, declared type
//    arguments, public endpoint/base views and linked stage observations.
//    Requests satisfy the grant precondition before send_request and response
//    IDs are copied from the actual request. Expected: Repeated interface
//    recording disable remains effective across the selected real request
//    traffic.
// 2. 1800.2-2020 15.2.1.2.11 (UVM-SQR-AUDIT-INTERFACE-RECORDING-QUERY) gives
//    rule 2 above. Setup: Use the selected original fixture, declared type
//    arguments, public endpoint/base views and linked stage observations.
//    Requests satisfy the grant precondition before send_request and response
//    IDs are copied from the actual request. Expected: The interface query
//    reports selected enabled/disabled recording states while an independent
//    peer retains its state.
// 3. 1800.2-2020 15.3.2.22 (UVM-SQR-AUDIT-BASE-RECORDING-DISABLE) gives rule 3
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Additionally disable twice through a base
//    handle before first connected pull/push traffic, with selected driver
//    marks omitted or explicitly supplied and an independent peer completing
//    its own request. Also disable the selected base before real pull/push
//    traffic while recording storage is explicitly enabled and an independent
//    peer remains in default automatic mode. Expected: The base
//    recording-disable API changes the selected sequencer state without
//    disabling an independent peer. Added no-mark inputs retain captured
//    transaction begin/end times and deliver no named begin/end notification.
//    Added manual inputs still accept exactly one explicit component begin/end
//    mark at the captured driver times. Both selected and peer traffic retain
//    the original request and block completion until their delayed driver work
//    returns; the added profiles do not assert peer automatic recording
//    counts. The added enabled-backend inputs deliver both original requests
//    but invoke no selected request custom-record hook or named property-field
//    hook; the peer still records its own distinct stable property through the
//    original backend.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequencer_interface_recording_disable_survives_real_traffic_and_preserves_peer;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class request_item extends uvm_sequence_item;
    `uvm_object_utils(request_item)
    int value=45;
    function new(string name="request"); super.new(name); endfunction
  endclass
  class response_item extends uvm_sequence_item;
    `uvm_object_utils(response_item)
    int value=145;
    function new(string name="response"); super.new(name); endfunction
  endclass
  class endpoint_owner extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class request_client extends endpoint_owner;
    uvm_seq_item_pull_port#(request_item,response_item) port;
    function new(string name,uvm_component parent);
      super.new(name,parent); port=new("port",this);
    endfunction
  endclass
  class producer extends uvm_sequence#(request_item,response_item);
    request_item sent;
    response_item received;
    bit request_completed=0,done=0;
    function new(string name="producer"); super.new(name); endfunction
    virtual task body();
      sent=new("sent45"); sent.set_transaction_id(451);
      start_item(sent); finish_item(sent); request_completed=1;
      // Keep the sequence live while response delivery precedes its waiter.
      #4; get_response(received,451); done=1;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(request_item,response_item) sequencer,peer;
    request_client client,other;
    endpoint_owner bridge;
    uvm_seq_item_pull_export#(request_item,response_item) relay;
    producer worker;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer=new("sequencer",this); peer=new("peer",this);
      client=new("client",this); other=new("other",this); bridge=new("bridge",this);
      relay=new("relay",bridge); worker=new();
    endfunction
    function void connect_phase(uvm_phase phase);
      client.port.connect(relay); relay.connect(sequencer.seq_item_export);
      other.port.connect(peer.seq_item_export);
    endfunction
    virtual task run_phase(uvm_phase phase);
      uvm_sqr_if_base#(request_item,response_item) view,peer_view;
      request_item observed,repeated,acknowledged;
      response_item reply;
      uvm_seq_item_pull_imp#(request_item,response_item,
                            uvm_sequencer#(request_item,response_item)) exact_imp;
      time before_put;
      uvm_sequencer_base base_view;
      phase.raise_objection(this);
      view=client.port.get_if(); peer_view=other.port.get_if();
      exact_imp=sequencer.seq_item_export;
      $display("UT: recording_default selected %0d peer %0d",
               view.is_auto_item_recording_enabled(),peer_view.is_auto_item_recording_enabled());
      base_view=sequencer; base_view.disable_auto_item_recording();
      $display("UT: recording_base_disabled selected %0d peer %0d",
               view.is_auto_item_recording_enabled(),peer_view.is_auto_item_recording_enabled());
      view.disable_auto_item_recording(); view.disable_auto_item_recording();
      $display("UT: recording_disabled selected %0d peer %0d",
               view.is_auto_item_recording_enabled(),peer_view.is_auto_item_recording_enabled());
      fork worker.start(sequencer); join_none
      view.get_next_item(observed); reply=new("reply"); reply.set_id_info(observed);
      view.item_done(reply); wait (worker.done);
      $display("UT: recording_after_traffic selected %0d peer %0d",
               view.is_auto_item_recording_enabled(),peer_view.is_auto_item_recording_enabled());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1,"test watchdog expired"); end

endmodule
