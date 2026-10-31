/*
:name: test_sequencer_killing_one_sequence_preserves_other_response_route
:description: termination and response routing preserve active receivers and reject retired routes (IEEE 1800.2-2020 Section 15.5.2.9)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.5.2.9 14.2.5.11 14.2.2.4 6.5.1.2.6 14.1.2.4 14.2.3.1 14.2.6.2 14.2.6.3 14.3.3.3 15.5.2.3 15.5.2.5 15.3.2.22 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_killing_one_sequence_preserves_other_response_route.expected
*/
// Keep two sequences active after completing their requests. Kill only
// the first, submit a stale reply for it, then deliver the second reply.
// The survivor must receive its own handle and payload normally.

module test_sequencer_killing_one_sequence_preserves_other_response_route;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class reply_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(reply_sequence)
    int value = 11;
    int transaction_value = 101;
    bit hold_after_request = 1;
    bit allow_finish = 0;
    bit read_reply = 0;
    bit request_done = 0;
    bit response_waiting = 0;
    bit response_returned = 0;
    bit finished = 0;
    int kills = 0;
    int handler_calls = 0;
    packet received;
    function new(string name="reply_sequence"); super.new(name); endfunction
    function void do_kill(); kills++; endfunction
    function void response_handler(uvm_sequence_item response);
      packet typed_response;
      if (!$cast(typed_response, response) || typed_response == null) $fatal(1, "invalid response");
      handler_calls++;
      received = typed_response;
    endfunction
    task body();
      packet request_value = new("request");
      request_value.payload = value;
      request_value.set_transaction_id(transaction_value);
      start_item(request_value);
      finish_item(request_value);
      request_done = 1;
      if (hold_after_request) wait (allow_finish);
      if (read_reply) begin
        response_waiting = 1;
        get_response(received);
        response_returned = 1;
      end
      finished = 1;
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    reply_sequence first;
    reply_sequence second;
    packet first_request;
    packet second_request;
    packet old_response;
    packet live_response;
    packet probe_response;
    bit first_returned = 0;
    bit second_returned = 0;
    bit probe_returned = 0;
    bit probe_done = 0;
    uvm_report_server report_server;
    int warning_before = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      first = new("first");
      second = new("second");
      second.value = 22;
      second.transaction_value = 202;
      report_server = uvm_report_server::get_server();
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    function packet make_response(packet request_value, int payload);
      packet result_value = new("response");
      result_value.set_id_info(request_value);
      result_value.payload = payload;
      return result_value;
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      second.read_reply = 1;

      fork
        begin first.start(sequencer); first_returned = 1; end
        begin #2; second.start(sequencer); second_returned = 1; end

        begin

          driver.seq_item_port.get_next_item(first_request);
          if (first_request == null) $fatal(1, "request missing");
          old_response = make_response(first_request, 77);
          #1;
          driver.seq_item_port.item_done();

          driver.seq_item_port.get_next_item(second_request);
          if (second_request == null) $fatal(1, "second request missing");
          live_response = make_response(second_request, 99);
          #1;
          driver.seq_item_port.item_done();
          wait (first.request_done && second.request_done);
          first.kill();
          wait (first_returned);
          warning_before = report_server.get_severity_count(UVM_WARNING);
          sequencer.put_response(old_response);
          $display("UT: warning_reported %0d",
              report_server.get_severity_count(UVM_WARNING) > warning_before);
          sequencer.put_response(live_response);
          second.allow_finish = 1;

        end
      join

      if (second.received == null) $fatal(1, "live response missing");
      $display("UT: first_stopped %0d survivor_finished %0d payload %0d same %0d",
               first.get_sequence_state() == UVM_STOPPED, second.finished, second.received.payload,
               second.received == live_response);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #100;
    $fatal(1, "test watchdog expired");
  end
endmodule
