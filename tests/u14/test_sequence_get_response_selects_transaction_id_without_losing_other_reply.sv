/*
:name: test_sequence_get_response_selects_transaction_id_without_losing_other_reply
:description: sequence get_response can select a later transaction while retaining the unmatched reply (IEEE 1800.2-2020 Section 14.3.3.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.3.3.3 14.1.2.4 15.5.2.9 5.4.2.18 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 15.3.2.22 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_get_response_selects_transaction_id_without_losing_other_reply.expected
*/
// What it checks:
// Response retrieval with a transaction ID selects the matching response.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.3.3.3 (UVM-RESPONSE-SELECT-ID) gives the rule above. Setup:
// Two queued responses carry IDs 101 and 102; ID 102 is requested first.
// Expected: Retrieval yields ID/value 102/22 followed by the retained 101/11.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Queue replies for requests 101 and 102, then retrieve 102 first.
// The transaction IDs are explicitly assigned by the test sequence.

module test_sequence_get_response_selects_transaction_id_without_losing_other_reply;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class response_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(response_sequence)
    int request_count = 2;
    int read_count = 2;
    int requested_ids[$];
    packet requests[$];
    packet received[$];
    packet handled[$];
    bit allow_read = 0;
    bit finished = 0;
    function new(string name="response_sequence"); super.new(name); endfunction
    function void response_handler(uvm_sequence_item response);
      packet typed_response;
      if (!$cast(typed_response, response) || typed_response == null) $fatal(1,
          "invalid response type");
      handled.push_back(typed_response);
    endfunction
    task body();
      packet request_value;
      packet response_value;
      int index;
      index = 0;
      repeat (request_count) begin
        request_value = new($sformatf("request_%0d", index));
        request_value.payload = 42 + index;
        request_value.set_transaction_id(101 + index);
        requests.push_back(request_value);
        start_item(request_value);
        finish_item(request_value);
        index++;
      end
      wait (allow_read);
      index = 0;
      repeat (read_count) begin
        if (requested_ids.size() == 0) get_response(response_value);
        else get_response(response_value, requested_ids[index]);
        received.push_back(response_value);
        index++;
      end
      finished = 1;
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;

    uvm_driver#(packet) driver;
    response_sequence sequence_value;
    uvm_report_server report_server;
    packet current_request;
    packet request_handles[$];
    packet first_response;
    packet second_response;
    packet third_response;
    packet latest_item;
    packet previous_item;
    int error_before = 0;
    int driver_index = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      sequence_value = new("sequence_value");
      report_server = uvm_report_server::get_server();
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);

    endfunction
    function packet make_response(packet request_value, int value);
      packet result_value = new("response");
      result_value.set_id_info(request_value);
      result_value.payload = value;
      return result_value;
    endfunction
    task run_phase(uvm_phase phase);
      uvm_root root = uvm_root::get();
      phase.raise_objection(this);
      root.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
      sequence_value.requested_ids.push_back(102);
      sequence_value.requested_ids.push_back(101);

      fork
        sequence_value.start(sequencer);
        begin
          repeat (sequence_value.request_count) begin
            driver.seq_item_port.get_next_item(current_request);
            if (current_request == null) $fatal(1, "request missing");
            request_handles.push_back(current_request);

            #1;
            driver.seq_item_port.item_done();
          end
          #1;

          first_response = make_response(request_handles[0], 11);
          second_response = make_response(request_handles[1], 22);
          sequencer.put_response(first_response);
          sequencer.put_response(second_response);

          sequence_value.allow_read = 1;
        end
      join

      if (sequence_value.received.size() != 2) $fatal(1, "response count differs");
      $display("UT: ids %0d %0d values %0d %0d", sequence_value.received[0].get_transaction_id(),
               sequence_value.received[1].get_transaction_id(), sequence_value.received[0].payload,
               sequence_value.received[1].payload);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
