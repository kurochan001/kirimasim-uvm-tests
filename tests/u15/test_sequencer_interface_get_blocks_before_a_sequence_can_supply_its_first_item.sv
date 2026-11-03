/*
:name: test_sequencer_interface_get_blocks_before_a_sequence_can_supply_its_first_item
:description: sequencer interface get blocks before a sequence can supply its first item
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.2.1.2.6 15.2.1.2.3 15.2.1.2.9 15.5.2.2 15.3.2.22 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_interface_get_blocks_before_a_sequence_can_supply_its_first_item.expected
*/
module test_sequencer_interface_get_blocks_before_a_sequence_can_supply_its_first_item;
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
    request_item blocking_observed;
    bit blocking_returned=0;
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
      request_item repeated,acknowledged;
      response_item reply;
      uvm_seq_item_pull_imp#(request_item,response_item,
                            uvm_sequencer#(request_item,response_item)) exact_imp;
      time before_put;
      phase.raise_objection(this);
      view=client.port.get_if(); peer_view=other.port.get_if();
      exact_imp=sequencer.seq_item_export;
      blocking_returned=0; view.disable_auto_item_recording();
      fork begin view.get(blocking_observed); blocking_returned=1; end join_none
      #1; $display("UT: blocking_interface_before returned %0d",blocking_returned);
      fork worker.start(sequencer); join_none
      wait (blocking_returned);
      if (blocking_observed==null) $fatal(1,"missing request");
      reply=new("reply"); reply.set_id_info(blocking_observed);
      view.put_response(reply);
      wait (worker.done);
      $display("UT: blocking_interface_after returned %0d same %0d completed %0d",
               blocking_returned,blocking_observed==worker.sent,worker.request_completed);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1,"test watchdog expired"); end

endmodule
