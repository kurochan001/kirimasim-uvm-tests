/*
:name: test_sequencer_response_routes_separate_live_sequences_with_the_same_transaction_id
:description: a response wakes only its originating sequence despite equal transaction IDs (IEEE 1800.2-2020 Section 15.5.2.9)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.5.2.9 14.1.2.4 14.3.3.3 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 15.3.2.22
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_response_routes_separate_live_sequences_with_the_same_transaction_id.expected
*/
// What it checks:
// Responses are routed to their originating live sequence, not merely by
// transaction ID.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.5.2.9 (UVM-SEQUENCER-LIVE-RESPONSE-ISOLATION) gives the rule
// above. Setup: Two live sequences wait with equal transaction IDs; send the
// second sequence reply first. Expected: Only the intended receiver wakes, and
// both eventually receive their original handles/data.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Request arrival order is unconstrained; payloads identify the two origins.
// Both receivers are blocked before the second response is sent first.
module test_sequencer_response_routes_separate_live_sequences_with_the_same_transaction_id;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class receiver extends uvm_sequence#(packet);
    `uvm_object_utils(receiver)
    int value = 11;
    bit waiting = 0;
    bit returned = 0;
    packet received;
    function new(string name="receiver"); super.new(name); endfunction
    task body();
      packet request;
      request = new("request");
      request.payload = value;
      request.set_transaction_id(77);
      start_item(request);
      finish_item(request);
      waiting = 1;
      get_response(received, 77);
      if (received == null) $fatal(1, "missing routed response");
      returned = 1;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    receiver first;
    receiver second;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      first = new("first");
      second = new("second");
      second.value = 22;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    function packet make_response(packet request, int value);
      packet response;
      response = new("response");
      response.set_id_info(request);
      response.payload = value;
      return response;
    endfunction
    task run_phase(uvm_phase phase);
      packet request;
      packet first_request;
      packet second_request;
      packet first_response;
      packet second_response;
      phase.raise_objection(this);
      fork
        first.start(sequencer);
        second.start(sequencer);
        begin
          repeat (2) begin
            driver.seq_item_port.get_next_item(request);
            if (request == null) $fatal(1, "request missing");
            if (request.payload == 11) first_request = request;
            else if (request.payload == 22) second_request = request;
            else $fatal(1, "unexpected request identity");
            #1;
            driver.seq_item_port.item_done();
          end
          if (first_request == null || second_request == null) $fatal(1, "origin missing");
          first_response = make_response(first_request, 111);
          second_response = make_response(second_request, 222);
          wait (first.waiting && second.waiting);
          #1;
          sequencer.put_response(second_response);
          #1;
          $display("UT: isolated first_waiting %0d second_returned %0d", !first.returned,
                   second.returned);
          sequencer.put_response(first_response);
        end
      join
      $display("UT: identities %0d %0d values %0d %0d", first.received == first_response,
               second.received == second_response, first.received.payload, second.received.payload);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "response-isolation watchdog expired"); end
endmodule
