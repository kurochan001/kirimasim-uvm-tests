/*
:name: test_sequencer_get_next_item_waits_for_item_done
:description: finish_item stays blocked until the driver acknowledges its retrieved request (IEEE 1800.2-2020 Section 15.5.2.3)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.5.2.3 15.5.2.5 14.2.6.6 15.3.2.22 15.5.2.2 15.2.2.1 14.2.6.2 14.2.6.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_get_next_item_waits_for_item_done.expected
*/
// What it checks:
// A retrieved request remains pending until the driver acknowledges it with
// item_done.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.5.2.3 (UVM-SEQUENCER-PULL-REQUEST-ACKNOWLEDGEMENT) gives the
// rule above. Setup: Retrieve one request handle and wait a positive delay
// before acknowledgement. Expected: The driver receives the original payload
// 42; finish_item remains pending before acknowledgement and completes
// afterwards.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Read the original request handle, wait a positive delay, and observe
// that the sequence has not finished before item_done is called.

module test_sequencer_get_next_item_waits_for_item_done;
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

          driver.seq_item_port.get_next_item(observed);
          if (observed == null) $fatal(1, "request missing");
          #1;
          $display("UT: request payload %0d same %0d finished_before_ack %0d", observed.payload,
                   observed == sequence_value.sent, sequence_value.finished);
          driver.seq_item_port.item_done();

        end
      join

      $display("UT: finished_after_ack %0d", sequence_value.finished);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
