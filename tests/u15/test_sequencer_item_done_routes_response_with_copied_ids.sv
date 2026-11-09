/*
:name: test_sequencer_item_done_routes_response_with_copied_ids
:description: item_done routes a response to the requesting sequence after copying request IDs (IEEE 1800.2-2020 Section 15.5.2.3)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.5.2.3 15.5.2.5 14.1.2.4 14.3.3.3 5.4.2.18 15.3.2.22 15.5.2.2 15.2.2.1 14.2.6.2 14.2.6.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_item_done_routes_response_with_copied_ids.expected
*/
// What it checks:
// item_done routes a supplied response with correct copied IDs to the
// requesting sequence.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.5.2.5 (UVM-SEQUENCER-DONE-RESPONSE) gives the rule above.
// Setup: A driver copies request IDs into a response with payload 99 and
// completes the item. Expected: The sequence receives that response handle,
// payload 99 and transaction ID 23.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use an explicit transaction ID and copy all routing IDs with
// set_id_info. Internal sequence ID values are never printed.

module test_sequencer_item_done_routes_response_with_copied_ids;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class request_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(request_sequence)
    packet sent;
    packet received_response;
    bit expect_response = 0;
    bit finished = 0;
    int request_count = 1;
    function new(string name="request_sequence"); super.new(name); endfunction
    task body();
      int index;
      index = 0;
      repeat (request_count) begin
        sent = new($sformatf("request_%0d", index));
        sent.payload = 42 + index;
        sent.set_transaction_id(23 + index);
        start_item(sent);
        finish_item(sent);
        index++;
      end
      if (expect_response) get_response(received_response);
      finished = 1;
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    request_sequence sequence_value;
    packet observed;
    packet peeked;
    packet removed;
    packet response;
    int first_payload = 0;
    int second_payload = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      sequence_value = new("sequence_value");
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      sequence_value.expect_response = 1;

      fork
        sequence_value.start(sequencer);
        begin

          driver.seq_item_port.get_next_item(observed);
          if (observed == null) $fatal(1, "request missing");
          response = new("response");
          response.set_id_info(observed);
          response.payload = 99;
          #1;
          driver.seq_item_port.item_done(response);

        end
      join

      if (sequence_value.received_response == null) $fatal(1, "response missing");
      $display("UT: response_same %0d payload %0d transaction_id %0d finished %0d",
               sequence_value.received_response == response,
                   sequence_value.received_response.payload,
               sequence_value.received_response.get_transaction_id(), sequence_value.finished);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
