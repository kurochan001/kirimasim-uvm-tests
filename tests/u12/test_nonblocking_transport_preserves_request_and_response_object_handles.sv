/*
:name: test_nonblocking_transport_preserves_request_and_response_object_handles
:description: nonblocking transport delivers the original request handle and the generated response handle (IEEE 1800.2-2020 Section 12.2.9.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.2.2 12.2.4.2.11 12.2.9.1.7 12.2.9.1.6 12.2.9.1.5 12.2.5.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_nonblocking_transport_preserves_request_and_response_object_handles.expected
*/
// The analysis responder receives an object request, creates a distinct
// reply and puts that handle through the response export. Compare typed
// handle values and payloads, not policy-specific clone or copy behavior.

module test_nonblocking_transport_preserves_request_and_response_object_handles;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class object_target extends uvm_subscriber#(packet);
    `uvm_component_utils(object_target)
    uvm_nonblocking_put_port#(packet) response_tx;
    packet last_request;
    packet last_response;
    bit accepted = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      response_tx = new("response_tx", this);
    endfunction
    function void write(packet t);
      if (t == null) $fatal(1, "request missing");
      last_request = t;
      last_response = new("response");
      last_response.payload = t.payload + 1;
      accepted = response_tx.try_put(last_response);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_transport_channel#(packet, packet) channel_value;
    uvm_nonblocking_transport_port#(packet, packet) initiator;
    uvm_nonblocking_get_port#(packet) request_rx;
    object_target target_value;
    packet request_value;
    packet response_value;
    packet retired_request;
    bit completed = 0;
    bit retired = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      channel_value = new("channel_value", this);
      initiator = new("initiator", this);
      request_rx = new("request_rx", this);
      target_value = new("target_value", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      initiator.connect(channel_value.transport_export);
      request_rx.connect(channel_value.get_peek_request_export);
      channel_value.request_ap.connect(target_value.analysis_export);
      target_value.response_tx.connect(channel_value.put_response_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      request_value = new("request");
      request_value.payload = 41;
      completed = initiator.nb_transport(request_value, response_value);
      if (response_value == null) $fatal(1, "response missing");
      retired = request_rx.try_get(retired_request);
      $display("UT: completed %0d payload %0d accepted %0d", completed, response_value.payload,
               target_value.accepted);
      $display("UT: request_same %0d response_same %0d distinct %0d retired %0d retired_same %0d",
               target_value.last_request == request_value,
                   target_value.last_response == response_value,
               request_value != response_value, retired, retired_request == request_value);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
