/*
:name: test_sequencer_rsp_export_updates_response_history_and_routes_replies
:description: responses delivered through rsp_export update last_rsp history and reach the waiting sequence (IEEE 1800.2-2020 Section 15.4.3.1)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.4.3.1 15.4.3.2 15.3.4.2.2 15.3.4.1 14.3.3.3 13.7.2.2 14.1.2.4 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 15.3.2.22 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_rsp_export_updates_response_history_and_routes_replies.expected
*/
// The driver analysis response port sends replies with copied request IDs.
// Inspect history after retrieval without assuming response handle copying.

module test_sequencer_rsp_export_updates_response_history_and_routes_replies;
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
      driver.rsp_port.connect(sequencer.rsp_export);

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
      sequencer.set_num_last_rsps(2);

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
          driver.rsp_port.write(first_response);
          driver.rsp_port.write(second_response);

          sequence_value.allow_read = 1;
        end
      join

      latest_item = sequencer.last_rsp();
      previous_item = sequencer.last_rsp(1);
      if (latest_item == null || previous_item == null) $fatal(1, "response history missing");
      $display("UT: history payloads %0d %0d ids %0d %0d", latest_item.payload,
               previous_item.payload, latest_item.get_transaction_id(),
                   previous_item.get_transaction_id());
      $display("UT: responses %0d received %0d beyond_null %0d", sequencer.get_num_rsps_received(),
               sequence_value.received.size(), sequencer.last_rsp(3) == null);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
