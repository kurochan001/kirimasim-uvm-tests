/*
:name: test_sequencer_and_sequence_current_item_span_peek_until_get
:description: current item queries retain a peeked request and clear when get acknowledges it (IEEE 1800.2-2020 Section 15.4.1)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.4.1 14.3.3.2 15.5.2.7 15.5.2.6 14.2.6.2 14.2.6.3 15.5.2.2 15.3.2.22 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_and_sequence_current_item_span_peek_until_get.expected
*/
// Repeated peek must leave both current-item APIs pointing to the request.
// Get acknowledges it implicitly; item_done is not called afterwards.

module test_sequencer_and_sequence_current_item_span_peek_until_get;
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
    packet observed;
    packet peeked;
    packet removed;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      sequence_value = new("sequence_value");
      sequence_value.request_count = 1;
      sequence_value.read_count = 0;
      sequence_value.allow_read = 1;

      fork
        sequence_value.start(sequencer);
        begin
          driver.seq_item_port.peek(observed);
          driver.seq_item_port.peek(peeked);
          if (observed == null || peeked == null) $fatal(1, "request missing");
          #1;
          $display("UT: peek_same %0d current_same %0d %0d", peeked == observed,
                   sequencer.get_current_item() == observed,
                   sequence_value.get_current_item() == observed);
          $display("UT: finished_before_get %0d", sequence_value.finished);
          driver.seq_item_port.get(removed);
        end
      join

      $display("UT: current_null %0d %0d consumed_same %0d finished %0d",
               sequencer.get_current_item() == null, sequence_value.get_current_item() == null,
               removed == observed, sequence_value.finished);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
