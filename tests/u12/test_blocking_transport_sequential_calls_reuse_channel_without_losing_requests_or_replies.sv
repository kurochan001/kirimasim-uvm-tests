/*
:name: test_blocking_transport_sequential_calls_reuse_channel_without_losing_requests_or_replies
:description: sequential blocking transport calls reuse request and response storage (IEEE 1800.2-2020 Section 12.2.9.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.2.2 12.2.9.2.1 12.2.9.2.3 12.2.9.1.5 12.2.9.1.6 12.2.4.2.10 12.2.4.2.1 12.2.4.2.2 12.2.5.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_blocking_transport_sequential_calls_reuse_channel_without_losing_requests_or_replies.expected
*/
// Use typed blocking ports and public transport-channel interfaces.
// Positive response delays establish wait/completion observations.
// No same-channel overlapping callers or protocol-specific matching is claimed.
module test_blocking_transport_sequential_calls_reuse_channel_without_losing_requests_or_replies;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class packet extends uvm_object;
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_transport_channel#(packet, packet) channel_value;
    uvm_tlm_transport_channel#(packet, packet) peer_channel;
    uvm_blocking_transport_port#(packet, packet) initiator;
    uvm_blocking_transport_port#(packet, packet) peer_initiator;
    uvm_blocking_get_port#(packet) request_rx;
    uvm_blocking_get_port#(packet) peer_request_rx;
    uvm_blocking_put_port#(packet) response_tx;
    uvm_blocking_put_port#(packet) peer_response_tx;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      channel_value = new("channel", this); peer_channel = new("peer_channel", this);
      initiator = new("initiator", this); peer_initiator = new("peer_initiator", this);
      request_rx = new("request_rx", this); peer_request_rx = new("peer_request_rx", this);
      response_tx = new("response_tx", this); peer_response_tx = new("peer_response_tx", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      initiator.connect(channel_value.transport_export);
      peer_initiator.connect(peer_channel.transport_export);
      request_rx.connect(channel_value.get_peek_request_export);
      peer_request_rx.connect(peer_channel.get_peek_request_export);
      response_tx.connect(channel_value.put_response_export);
      peer_response_tx.connect(peer_channel.put_response_export);
    endfunction
    task run_phase(uvm_phase phase);

      packet first_request = new("first");
      packet second_request = new("second");
      packet first_reply;
      packet second_reply;
      packet requests[$];
      packet replies[$];

      phase.raise_objection(this);

      first_request.payload = 11; second_request.payload = 22;
      fork
        begin
          initiator.transport(first_request, first_reply);
          initiator.transport(second_request, second_reply);
        end
        begin
          repeat (2) begin
            packet request_seen;
            packet response_sent;
            request_rx.get(request_seen); requests.push_back(request_seen); #2;
            response_sent = new("reply"); response_sent.payload = request_seen.payload + 10;
            replies.push_back(response_sent); response_tx.put(response_sent);
          end
        end
      join
      if (requests.size() != 2 || replies.size() != 2 || first_reply == null ||
      second_reply == null) $fatal(1, "missing transfer");
      $display("UT: values %0d %0d requests %0d %0d", first_reply.payload, second_reply.payload,
      requests[0] == first_request, requests[1] == second_request);
      $display("UT: replies %0d %0d distinct %0d", first_reply == replies[0],
      second_reply == replies[1], first_reply != second_reply);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "blocking transport watchdog expired"); end

endmodule
