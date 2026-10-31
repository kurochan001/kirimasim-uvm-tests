/*
:name: test_sequence_response_control_updates_are_per_instance
:description: sequence response control updates leave another sequence configuration unchanged (IEEE 1800.2-2020 Section 14.2.7.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.7.1 14.2.7.2 14.2.7.4 14.2.7.5 14.2.7.6 14.2.7.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_response_control_updates_are_per_instance.expected
*/
// Select an unbounded response depth on one sequence. This case only
// checks configuration; runtime unbounded storage has its own case.
// The untouched sequence must retain the required enabled error-report
// default. The pinned library initializes that bit to zero instead.

module test_sequence_response_control_updates_are_per_instance;
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

  initial begin
    automatic response_sequence first = new("first");
    automatic response_sequence second = new("second");
    first.use_response_handler(1);
    first.set_response_queue_depth(-1);
    first.set_response_queue_error_report_enabled(0);
    $display("UT: first handler %0d depth %0d errors %0d", first.get_use_response_handler(),
             first.get_response_queue_depth(), first.get_response_queue_error_report_enabled());
    $display("UT: second handler %0d depth %0d errors %0d", second.get_use_response_handler(),
             second.get_response_queue_depth(), second.get_response_queue_error_report_enabled());
    $finish;
  end
endmodule
