/*
:name: test_sequence_targeted_reads_retain_both_matching_duplicate_ids_and_unmatched_reply
:description: repeated targeted reads retain both duplicate-ID replies without requiring their tie order (IEEE 1800.2-2020 Section 14.3.3.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.3.3.3 14.1.2.4 15.5.2.9 5.4.2.18 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 15.3.2.22
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_targeted_reads_retain_both_matching_duplicate_ids_and_unmatched_reply.expected
*/
// What it checks:
// Repeated targeted reads retrieve distinct matching queued replies without
// discarding another ID.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.3.3.3 (UVM-SEQUENCE-MATCHING-DUPLICATE-RESPONSES) gives the
// rule above. Setup: Two replies share an explicit transaction ID and one has
// another ID. Expected: Both matching handles are returned once and the
// unmatched handle remains; matching tie order is unconstrained.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive delays distinguish a real wait from delta-cycle scheduling.
// Responses copy both routing IDs from real acknowledged requests.
module test_sequence_targeted_reads_retain_both_matching_duplicate_ids_and_unmatched_reply;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class receiver extends uvm_sequence#(packet);
    `uvm_object_utils(receiver)
    bit waiting = 0;
    bit allow_read = 0;
    int waiting_stage = 0;
    int completed = 0;
    packet received[$];
    function new(string name="receiver"); super.new(name); endfunction
    task body();
      packet request;
      packet response;
      for (int i = 0; i < 3; i++) begin
        request = new($sformatf("request%0d", i));
        request.payload = 10 + i;
        request.set_transaction_id(i == 0 ? 101 : 102);
        start_item(request);
        finish_item(request);
      end
      wait (allow_read);
      repeat (2) begin
        get_response(response, 102);
        if (response == null) $fatal(1, "missing matching response");
        received.push_back(response);
      end
      get_response(response);
      if (response == null) $fatal(1, "missing unmatched response");
      received.push_back(response);

    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    receiver sequence_value;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      sequence_value = new();
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
      packet requests[$];
      packet first_response;
      packet second_response;
      packet third_response;
      int second_seen;
      int third_seen;
      phase.raise_objection(this);
      fork
        sequence_value.start(sequencer);
        begin
          repeat (3) begin
            driver.seq_item_port.get_next_item(request);
            if (request == null) $fatal(1, "request missing");
            requests.push_back(request);
            #1;
            driver.seq_item_port.item_done();
          end
          first_response = make_response(requests[0], 111);
          second_response = make_response(requests[1], 222);
          third_response = make_response(requests[2], 333);
          sequencer.put_response(first_response);
          sequencer.put_response(second_response);
          sequencer.put_response(third_response);
          sequence_value.allow_read = 1;

        end
      join
      if (sequence_value.received.size() != 3) $fatal(1, "response count differs");
      second_seen = 0;
      third_seen = 0;
      for (int i = 0; i < 2; i++) begin
        if (sequence_value.received[i] == second_response) second_seen++;
        if (sequence_value.received[i] == third_response) third_seen++;
      end
      $display("UT: matching_membership %0d %0d ids %0d unmatched %0d",
               second_seen == 1, third_seen == 1,
               sequence_value.received[0].get_transaction_id() == 102 &&
               sequence_value.received[1].get_transaction_id() == 102,
               sequence_value.received[2] == first_response);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "response-wait watchdog expired"); end
endmodule
