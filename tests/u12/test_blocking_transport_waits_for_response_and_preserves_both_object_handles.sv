/*
:name: test_blocking_transport_waits_for_response_and_preserves_both_object_handles
:description: blocking transport waits for a response and preserves request and reply handles (IEEE 1800.2-2020 Section 12.2.9.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.2.2 12.2.9.2.1 12.2.9.2.3 12.2.9.1.5 12.2.9.1.6 12.2.4.2.10 12.2.4.2.1 12.2.4.2.2 12.2.5.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_blocking_transport_waits_for_response_and_preserves_both_object_handles.expected
*/
// Use typed blocking ports and public transport-channel interfaces.
// Positive response delays establish wait/completion observations.
// No same-channel overlapping callers or protocol-specific matching is claimed.
module test_blocking_transport_waits_for_response_and_preserves_both_object_handles;
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

      packet request_value = new("request");
      packet response_value;
      packet request_seen;
      packet response_sent;
      bit completed = 0;

      phase.raise_objection(this);

      request_value.payload = 41;
      fork
        begin initiator.transport(request_value, response_value); completed = 1; end
        begin
          request_rx.get(request_seen); #2;
          response_sent = new("reply"); response_sent.payload = request_seen.payload + 1;
          response_tx.put(response_sent);
        end
        begin #1; $display("UT: before_reply completed %0d", completed); end
      join
      if (response_value == null) $fatal(1, "response missing");
      $display("UT: returned %0d value %0d request_same %0d response_same %0d", completed,
      response_value.payload, request_seen == request_value, response_value == response_sent);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "blocking transport watchdog expired"); end

endmodule
