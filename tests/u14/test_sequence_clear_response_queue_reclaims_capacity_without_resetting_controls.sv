/*
:name: test_sequence_clear_response_queue_reclaims_capacity_without_resetting_controls
:description: clearing a full response queue permits a fresh bounded batch and preserves controls (IEEE 1800.2-2020 Section 14.2.7.8)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.7.8 14.2.7.2 14.2.7.4 14.2.7.5 14.2.7.6 14.2.7.7 14.3.3.3 14.1.2.4 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 15.5.2.9 15.3.2.22 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_clear_response_queue_reclaims_capacity_without_resetting_controls.expected
*/
// What it checks:
// 1. Clearing a full response queue reclaims its bounded storage.
// 2. Clearing queue contents retains separately selected response controls.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.7.8 (UVM-RESPONSE-CLEAR-RECLAIMS-CAPACITY) gives rule 1
//    above. Setup: Fill a depth-two queue, clear twice, refill with two fresh
//    replies and retrieve them. Expected: Both exact fresh handles return in
//    arrival order with values 55/66 and no additional error.
// 2. 1800.2-2020 14.2.7.8 (UVM-RESPONSE-CLEAR-PRESERVES-CONTROLS) gives rule 2
//    above. Setup: Select depth two and queue mode, snapshot reporting, then
//    clear twice. Expected: Depth remains two and handler/reporting getters
//    retain their earlier values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Copy routing IDs from real requests while the receiver remains active.
// Positive delays separate queue operations from observation; no internal
// response queue or numeric sequence-routing ID is inspected.
// Control preservation compares before/after getters without reasserting
// the separately tracked error-enable default/setter interpretation.
module test_sequence_clear_response_queue_reclaims_capacity_without_resetting_controls;
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

      first.request_count = 2; first.read_count = 2; first.set_response_queue_depth(2);
      first.use_response_handler(0); first.set_response_queue_error_report_enabled(1);
      handler_before = first.get_use_response_handler();
      reporting_before = first.get_response_queue_error_report_enabled();
      errors_before = report_server.get_severity_count(UVM_ERROR);
      fork
        first.start(sequencer);
        begin
          collect_first_requests();
          first_reply = reply(requests[0], 11); second_reply = reply(requests[1], 22);
          fresh_first = reply(requests[0], 55); fresh_second = reply(requests[1], 66);
          sequencer.put_response(first_reply); sequencer.put_response(second_reply);
          first.clear_response_queue(); first.clear_response_queue();
          $display("UT: retained depth %0d handler %0d reporting %0d",
          first.get_response_queue_depth(), first.get_use_response_handler() == handler_before,
          first.get_response_queue_error_report_enabled() == reporting_before);
          sequencer.put_response(fresh_first); sequencer.put_response(fresh_second);
          first.allow_read = 1;
        end
      join
      $display("UT: fresh_batch count %0d exact %0d %0d values %0d %0d", first.received.size(),
      first.received[0] == fresh_first, first.received[1] == fresh_second,
      first.received[0].payload, first.received[1].payload);
      $display("UT: no_new_error %0d",
      report_server.get_severity_count(UVM_ERROR) == errors_before);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "response queue watchdog expired"); end

endmodule
