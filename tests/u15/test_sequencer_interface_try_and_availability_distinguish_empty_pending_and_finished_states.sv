/*
:name: test_sequencer_interface_try_and_availability_distinguish_empty_pending_and_finished_states
:description: sequencer interface try and availability distinguish empty pending and finished states
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.2.1.2.2 15.2.1.2.5 15.2.1.2.3 15.5.2.2 15.3.2.22 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_interface_try_and_availability_distinguish_empty_pending_and_finished_states.expected
*/
// What it checks:
// 1. try_next_item returns null when no sequence can supply an item, before
//    and after selected traffic.
// 2. try_next_item returns the selected pending request without acknowledging
//    it.
// 3. The selected empty and ready try_next_item calls do not advance
//    simulation time.
// 4. has_do_available distinguishes empty/finished traffic from an eligible
//    pending sequence.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.2.1.2.2 (UVM-SQR-AUDIT-INTERFACE-TRY-EMPTY) gives rule 1
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: try_next_item returns null when
//    no sequence can supply an item, before and after selected traffic.
// 2. 1800.2-2020 15.2.1.2.2 (UVM-SQR-AUDIT-INTERFACE-TRY-PENDING) gives rule 2
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: try_next_item returns the
//    selected pending request without acknowledging it.
// 3. 1800.2-2020 15.2.1.2.2 (UVM-SQR-AUDIT-INTERFACE-TRY-NO-TIME) gives rule 3
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: The selected empty and ready
//    try_next_item calls do not advance simulation time.
// 4. 1800.2-2020 15.2.1.2.5 (UVM-SQR-AUDIT-INTERFACE-AVAILABLE) gives rule 4
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: has_do_available distinguishes
//    empty/finished traffic from an eligible pending sequence.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequencer_interface_try_and_availability_distinguish_empty_pending_and_finished_states;
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
      before_put=$time; view.try_next_item(observed);
      $display("UT: interface_empty_try null %0d no_time %0d available %0d",
               observed==null,$time==before_put,view.has_do_available());
      fork worker.start(sequencer); join_none
      #1;
      $display("UT: interface_pending_available %0d",view.has_do_available());
      before_put=$time; view.try_next_item(observed);
      if (observed==null) $fatal(1,"pending request missing");
      $display("UT: interface_ready_try same %0d no_time %0d completed %0d",
               observed==worker.sent,$time==before_put,worker.request_completed);
      reply=new("reply"); reply.set_id_info(observed); view.item_done(reply);
      wait (worker.done);
      before_put=$time; view.try_next_item(observed);
      $display("UT: interface_finished_try null %0d no_time %0d available %0d",
               observed==null,$time==before_put,view.has_do_available());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1,"test watchdog expired"); end

endmodule
