/*
:name: test_sequencer_user_arbitration_calls_override_with_one_candidate
:description: USER arbitration calls the override even when only one sequence is available (IEEE 1800.2-2020 Section 15.3.2.3)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.3 15.3.2.4 15.3.2.19 F.2.4.1 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 15.3.2.22 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_user_arbitration_calls_override_with_one_candidate.expected
*/
// The standard requires the USER callback even for one candidate. The
// pinned library returns that candidate before the callback; preserve this
// spec-only expectation and check the callback mapping when it is invoked.

module test_sequencer_user_arbitration_calls_override_with_one_candidate;
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

  class user_sequencer extends uvm_sequencer#(packet);
    `uvm_component_utils(user_sequencer)
    uvm_sequence_base expected_source;
    int calls = 0;
    bit selected_source_matches = 1;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function int user_priority_arbitration(int avail_sequences[$]);
      if (avail_sequences.size() == 0) $fatal(1, "no arbitration candidate");
      calls++;
      if (get_arbitration_sequence(avail_sequences[0]) != expected_source)
        selected_source_matches = 0;
      return avail_sequences[0];
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    user_sequencer sequencer;

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
      sequence_value.request_count = 1;
      sequence_value.read_count = 0;
      sequencer.set_arbitration(UVM_SEQ_ARB_USER);
      sequencer.expected_source = sequence_value;

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

          sequence_value.allow_read = 1;
        end
      join

      $display("UT: override_called %0d source_matches %0d finished %0d", sequencer.calls > 0,
               sequencer.selected_source_matches, sequence_value.finished);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
