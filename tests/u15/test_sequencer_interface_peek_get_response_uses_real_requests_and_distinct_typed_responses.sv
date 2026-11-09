/*
:name: test_sequencer_interface_peek_get_response_uses_real_requests_and_distinct_typed_responses
:description: sequencer interface peek get response uses real requests and distinct typed responses
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.2.1.2.7 15.2.1.2.6 15.2.1.2.9 15.2.1.1 15.2.2.1 15.2.2.2 15.2.2.3 15.5.2.2 14.3.3.3 15.3.2.22 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_interface_peek_get_response_uses_real_requests_and_distinct_typed_responses.expected
*/
// What it checks:
// 1. Repeated peek returns the same current request before get retrieves it.
// 2. put_response routes the typed response to the sequence that issued the
//    request.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.2.1.2.7 (UVM-SQR-AUDIT-INTERFACE-PEEK-CURRENT) gives rule
//    1 above. Setup: Use the selected original fixture, declared type
//    arguments, public endpoint/base views and linked stage observations.
//    Requests satisfy the grant precondition before send_request and response
//    IDs are copied from the actual request. Expected: Repeated peek returns
//    the same current request before get retrieves it.
// 2. 1800.2-2020 15.2.1.2.9 (UVM-SQR-AUDIT-INTERFACE-PUT-RESPONSE-FUNCTION)
//    gives rule 2 above. Setup: Use the selected original fixture, declared
//    type arguments, public endpoint/base views and linked stage observations.
//    Requests satisfy the grant precondition before send_request and response
//    IDs are copied from the actual request. Expected: put_response routes the
//    typed response to the sequence that issued the request.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequencer_interface_peek_get_response_uses_real_requests_and_distinct_typed_responses;
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
      phase.raise_objection(this);
      view=client.port.get_if(); peer_view=other.port.get_if();
      exact_imp=sequencer.seq_item_export;
      view.disable_auto_item_recording();
      fork worker.start(sequencer); join_none
      view.peek(observed); view.peek(repeated);
      $display("UT: interface_repeated_peek %0d",observed==repeated);
      if (observed==null) $fatal(1,"missing request");
      #1;
      $display("UT: interface_request same %0d value %0d completed %0d",
               observed==worker.sent,observed.value,worker.request_completed);
      reply=new("reply"); reply.set_id_info(observed);
      view.get(acknowledged);
      $display("UT: interface_get_same %0d",acknowledged==observed);
      view.put_response(reply);
      wait (worker.done);
      $display("UT: interface_reply same %0d value %0d completed %0d",
               worker.received==reply,worker.received.value,worker.request_completed);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1,"test watchdog expired"); end

endmodule
