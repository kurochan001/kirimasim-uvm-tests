/*
:name: test_sequencer_peek_keeps_current_request_until_get
:description: sequencer peek retains the same request until get consumes and acknowledges it (IEEE 1800.2-2020 Section 15.5.2.7)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.5.2.7 15.5.2.6 14.2.6.6 15.3.2.22 15.5.2.2 15.2.2.1 14.2.6.2 14.2.6.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_peek_keeps_current_request_until_get.expected
*/
// Observe repeated peeks while finish_item is blocked. Get implicitly
// acknowledges the request, so item_done is not called afterwards.

module test_sequencer_peek_keeps_current_request_until_get;
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

      fork
        sequence_value.start(sequencer);
        begin

          driver.seq_item_port.peek(observed);
          driver.seq_item_port.peek(peeked);
          if (observed == null || peeked == null) $fatal(1, "request missing");
          #1;
          $display("UT: peek_same %0d payload %0d finished_before_get %0d", observed == peeked,
                   observed.payload, sequence_value.finished);
          driver.seq_item_port.get(removed);

        end
      join

      $display("UT: consumed_same %0d finished %0d", removed == observed, sequence_value.finished);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
