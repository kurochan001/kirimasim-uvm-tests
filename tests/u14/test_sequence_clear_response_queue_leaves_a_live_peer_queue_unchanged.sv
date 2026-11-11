/*
:name: test_sequence_clear_response_queue_leaves_a_live_peer_queue_unchanged
:description: clearing one response queue leaves a different live sequence queue intact (IEEE 1800.2-2020 Section 14.2.7.8)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.7.8 14.3.3.3 14.1.2.4 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 15.5.2.9 15.3.2.22 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_clear_response_queue_leaves_a_live_peer_queue_unchanged.expected
*/
// What it checks:
// Clearing one live sequence queue leaves a peer queue available.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.2.7.8 (UVM-RESPONSE-CLEAR-INSTANCE-ISOLATION) gives the rule
// above. Setup: Queue replies for two live sequences, clear first and retrieve
// peer before sending first a fresh reply. Expected: Peer receives its exact
// reply 77; first remains waiting and later receives only its fresh reply 22.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Copy routing IDs from real requests while the receiver remains active.
// Positive delays separate queue operations from observation; no internal
// response queue or numeric sequence-routing ID is inspected.
// Control preservation compares before/after getters without reasserting
// the separately tracked error-enable default/setter interpretation.
module test_sequence_clear_response_queue_leaves_a_live_peer_queue_unchanged;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class receiver_sequence extends uvm_sequence#(packet);
    int request_count = 3;
    int base_id = 101;
    int read_count = 1;
    int selectors[$];
    packet received[$];
    bit requests_done = 0;
    bit allow_read = 0;
    bit finished = 0;
    function new(string name); super.new(name); endfunction
    virtual task body();
      packet request_value;
      packet response_value;
      repeat (request_count) begin
        request_value = new("request");
        request_value.set_transaction_id(base_id++);
        start_item(request_value); finish_item(request_value);
      end
      requests_done = 1;
      wait (allow_read);
      for (int i=0; i<read_count; i++) begin
        if (selectors.size() == 0) get_response(response_value);
        else get_response(response_value, selectors[i]);
        received.push_back(response_value);
      end
      finished = 1;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    receiver_sequence first;
    receiver_sequence peer;
    packet requests[$];
    packet peer_request;
    packet first_reply;
    packet second_reply;
    packet third_reply;
    packet fresh_first;
    packet fresh_second;
    packet peer_reply;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this); sequencer.disable_auto_item_recording();
      driver = new("driver", this); first = new("first"); peer = new("peer");
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    function packet reply(packet request_value, int value);
      packet result_value = new("reply");
      result_value.set_id_info(request_value); result_value.payload = value; return result_value;
    endfunction
    task collect_first_requests();
      packet request_value;
      repeat (first.request_count) begin
        driver.seq_item_port.get_next_item(request_value);
        if (request_value == null) $fatal(1, "request missing");
        requests.push_back(request_value); #1; driver.seq_item_port.item_done();
      end
      wait (first.requests_done);
    endtask
    task run_phase(uvm_phase phase);
      bit handler_before;
      bit reporting_before;
      int errors_before;
      uvm_report_server report_server = uvm_report_server::get_server();
      phase.raise_objection(this);

      first.request_count = 2; peer.request_count = 1; peer.base_id = 201;
      fork
        first.start(sequencer);
        begin
          collect_first_requests();
          fork
            peer.start(sequencer);
            begin
              driver.seq_item_port.get_next_item(peer_request);
              if (peer_request == null) $fatal(1, "peer request missing");
              #1; driver.seq_item_port.item_done(); wait (peer.requests_done);
              first_reply = reply(requests[0], 11); fresh_first = reply(requests[1], 22);
              peer_reply = reply(peer_request, 77);
              sequencer.put_response(first_reply); sequencer.put_response(peer_reply);
              first.clear_response_queue(); peer.allow_read = 1; #2;
              $display("UT: peer_after_clear finished %0d exact %0d value %0d", peer.finished,
              peer.received.size() == 1 && peer.received[0] == peer_reply,
              peer.received[0].payload);
              first.allow_read = 1; #2;
              $display("UT: cleared_first_waiting received %0d finished %0d",
              first.received.size(), first.finished);
              sequencer.put_response(fresh_first);
            end
          join
        end
      join
      $display("UT: first_fresh count %0d exact %0d value %0d", first.received.size(),
      first.received[0] == fresh_first, first.received[0].payload);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "response queue watchdog expired"); end

endmodule
