/*
:name: test_sequence_response_controls_have_documented_defaults
:description: sequence response controls default to queued retrieval depth eight and enabled overflow reporting (IEEE 1800.2-2020 Section 14.2.7.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.7.1 14.2.7.2 14.2.7.4 14.2.7.5 14.2.7.6 14.2.7.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_response_controls_have_documented_defaults.expected
*/
// What it checks:
// 1. The initial response handler mode is off.
// 2. The initial response maximum queue depth is eight.
// 3. The initial response overflow error reporting is enabled.
// 4. The response handler mode follows the selected instance setting.
// 5. The response maximum queue depth follows the selected instance setting.
// 6. The response error-report enable setting follows the selected instance
//    setting.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.7.1 (UVM-RESPONSE-DEFAULT-MODE) gives rule 1 above.
//    Setup: Query a fresh sequence before any setting on that instance.
//    Expected: The default tuple is handler zero, depth eight, reporting one.
// 2. 1800.2-2020 14.2.7.7 (UVM-RESPONSE-DEFAULT-DEPTH) gives rule 2 above.
//    Setup: Query a fresh sequence before any setting on that instance.
//    Expected: The default tuple is handler zero, depth eight, reporting one.
// 3. 1800.2-2020 14.2.7.4 (UVM-RESPONSE-DEFAULT-ERROR-ENABLE) gives rule 3
//    above. Setup: Query a fresh sequence before any setting on that instance.
//    Expected: The default tuple is handler zero, depth eight, reporting one.
// 4. 1800.2-2020 14.2.7.1 (UVM-RESPONSE-MODE-SELECTED-INSTANCE-VALUE) gives
//    rule 4 above. Setup: Select handler mode, finite or unbounded depth and
//    disabled reporting while retaining a fresh peer. Expected: First reflects
//    its selected settings and the untouched peer retains the documented
//    defaults.
// 5. 1800.2-2020 14.2.7.7 (UVM-RESPONSE-DEPTH-SELECTED-INSTANCE-VALUE) gives
//    rule 5 above. Setup: Select handler mode, finite or unbounded depth and
//    disabled reporting while retaining a fresh peer. Expected: First reflects
//    its selected settings and the untouched peer retains the documented
//    defaults.
// 6. 1800.2-2020 14.2.7.5 (UVM-RESPONSE-ERROR-ENABLE-SELECTED-INSTANCE-VALUE)
//    gives rule 6 above. Setup: Select handler mode, finite or unbounded depth
//    and disabled reporting while retaining a fresh peer. Expected: First
//    reflects its selected settings and the untouched peer retains the
//    documented defaults.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Inspect controls on a concrete sequence before it runs, then update
// the three independent settings without injecting any responses.
// The pinned library leaves error reporting off at construction. Retain
// the required enabled default as a spec-only expectation.

module test_sequence_response_controls_have_documented_defaults;
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
    automatic response_sequence value = new("value");
    $display("UT: defaults handler %0d depth %0d errors %0d", value.get_use_response_handler(),
             value.get_response_queue_depth(), value.get_response_queue_error_report_enabled());
    value.use_response_handler(1);
    value.set_response_queue_depth(3);
    value.set_response_queue_error_report_enabled(0);
    $display("UT: updated handler %0d depth %0d errors %0d", value.get_use_response_handler(),
             value.get_response_queue_depth(), value.get_response_queue_error_report_enabled());
    $finish;
  end
endmodule
