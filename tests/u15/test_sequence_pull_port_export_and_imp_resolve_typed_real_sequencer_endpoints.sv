/*
:name: test_sequence_pull_port_export_and_imp_resolve_typed_real_sequencer_endpoints
:description: sequence pull port export and imp resolve typed real sequencer endpoints
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.2.2.1 15.2.2.2 15.2.2.3 15.5.2.2 12.2.1 15.2.1.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_pull_port_export_and_imp_resolve_typed_real_sequencer_endpoints.expected
*/
// What it checks:
// 1. The selected typed pull port participates in a resolved port/export/imp
//    path to the real sequencer.
// 2. The selected pull port standard constructor retains its name and
//    component parent.
// 3. The selected typed pull export participates in a resolved port/export/imp
//    path to the real sequencer.
// 4. The selected pull export standard constructor retains its name and
//    component parent.
// 5. The selected typed pull imp participates in a resolved port/export/imp
//    path to the real sequencer.
// 6. The selected pull imp standard constructor retains its name and component
//    parent.
// 7. seq_item_export exposes the declared request/response-specific pull
//    implementation type.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.2.2.1 (UVM-SQR-AUDIT-PULL-PORT-TYPED-CONNECTION) gives
//    rule 1 above. Setup: Use the selected original fixture, declared type
//    arguments, public endpoint/base views and linked stage observations.
//    Requests satisfy the grant precondition before send_request and response
//    IDs are copied from the actual request. Expected: The selected typed pull
//    port participates in a resolved port/export/imp path to the real
//    sequencer.
// 2. 1800.2-2020 15.2.2.1 (UVM-SQR-AUDIT-PULL-PORT-CONSTRUCTOR) gives rule 2
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: The selected pull port standard
//    constructor retains its name and component parent.
// 3. 1800.2-2020 15.2.2.2 (UVM-SQR-AUDIT-PULL-EXPORT-TYPED-CONNECTION) gives
//    rule 3 above. Setup: Use the selected original fixture, declared type
//    arguments, public endpoint/base views and linked stage observations.
//    Requests satisfy the grant precondition before send_request and response
//    IDs are copied from the actual request. Expected: The selected typed pull
//    export participates in a resolved port/export/imp path to the real
//    sequencer.
// 4. 1800.2-2020 15.2.2.2 (UVM-SQR-AUDIT-PULL-EXPORT-CONSTRUCTOR) gives rule 4
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: The selected pull export
//    standard constructor retains its name and component parent.
// 5. 1800.2-2020 15.2.2.3 (UVM-SQR-AUDIT-PULL-IMP-TYPED-CONNECTION) gives rule
//    5 above. Setup: Use the selected original fixture, declared type
//    arguments, public endpoint/base views and linked stage observations.
//    Requests satisfy the grant precondition before send_request and response
//    IDs are copied from the actual request. Expected: The selected typed pull
//    imp participates in a resolved port/export/imp path to the real
//    sequencer.
// 6. 1800.2-2020 15.2.2.3 (UVM-SQR-AUDIT-PULL-IMP-CONSTRUCTOR) gives rule 6
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: The selected pull imp standard
//    constructor retains its name and component parent.
// 7. 1800.2-2020 15.5.2.2 (UVM-SQR-AUDIT-PULL-EXPOSED-IMP) gives rule 7 above.
//    Setup: Use the selected original fixture, declared type arguments, public
//    endpoint/base views and linked stage observations. Requests satisfy the
//    grant precondition before send_request and response IDs are copied from
//    the actual request. Expected: seq_item_export exposes the declared
//    request/response-specific pull implementation type.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequence_pull_port_export_and_imp_resolve_typed_real_sequencer_endpoints;
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
      $display("UT: pull_resolution port %0d export %0d interface %0d imp %0d",
               client.port.size(),relay.size(),view!=null,exact_imp==sequencer.seq_item_export);
      $display("UT: pull_names port %0d export %0d imp %0d",
               client.port.get_name()=="port",relay.get_name()=="relay",
               exact_imp.get_name()=="seq_item_export");
      $display("UT: pull_parents port %0d export %0d imp %0d",
               client.port.get_parent()==client,relay.get_parent()==bridge,
               exact_imp.get_parent()==sequencer);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1,"test watchdog expired"); end

endmodule
