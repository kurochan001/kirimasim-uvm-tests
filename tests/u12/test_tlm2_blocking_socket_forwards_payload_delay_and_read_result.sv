/*
:name: test_tlm2_blocking_socket_forwards_payload_delay_and_read_result
:description: TLM 2 blocking sockets forward payload and delay handles and expose the completed read result (IEEE 1800.2-2020 Section 12.3.2.2.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.2.2.3 12.3.5.1.3 12.3.5.2.3 12.3.5.2.4 12.3.4.2.24 12.3.4.2.25 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_blocking_socket_forwards_payload_delay_and_read_result.expected
*/
// What it checks:
// Blocking sockets forward original transaction/delay handles and return the
// completed read data.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.2.2.3 (UVM-TLM2-BLOCKING-SOCKET-READ) gives the rule above.
// Setup: Execute one valid two-byte read through ordinary sockets. Expected:
// Target sees both exact handles once; caller gets OK and bytes 01/80 hex.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Initialize a valid two-byte read request and pass one delay object.
// The target fills read data and sets response status before returning.

module test_tlm2_blocking_socket_forwards_payload_delay_and_read_result;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class blocking_target extends uvm_component;
    `uvm_component_utils(blocking_target)
    uvm_tlm_b_target_socket#(blocking_target) socket;
    uvm_tlm_generic_payload expected_payload;
    uvm_tlm_time expected_delay;
    int calls = 0;
    bit [63:0] addresses[$];
    function new(string name, uvm_component parent);
      super.new(name, parent);
      socket = new("socket", this, this);
    endfunction
    task b_transport(uvm_tlm_generic_payload t, uvm_tlm_time delay);
      byte unsigned data[];
      calls++;
      addresses.push_back(t.get_address());
      $display("UT: target call %0d payload_same %0d delay_same %0d", calls,
          t == expected_payload, delay == expected_delay);
      t.get_data(data);
      if (data.size() != 2 || !t.is_read()) $fatal(1, "unexpected read request");
      data[0] = calls;
      data[1] = 8'h80;
      t.set_data(data);
      #1;
      t.set_response_status(UVM_TLM_OK_RESPONSE);
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_b_initiator_socket#() initiator;
    blocking_target target;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      initiator = new("initiator", this);
      target = new("target", this);
    endfunction
    function void connect_phase(uvm_phase phase); initiator.connect(target.socket); endfunction
    task run_phase(uvm_phase phase);
      uvm_tlm_generic_payload payload = new("payload");
      uvm_tlm_time delay_value = new("delay_value");
      byte unsigned data[];
      byte unsigned mask[];
      int first_value;
      phase.raise_objection(this);
      data = new[2];
      data[0] = 0;
      data[1] = 0;
      mask = new[0];
      payload.set_read();
      payload.set_address(64'h100);
      payload.set_data(data);
      payload.set_data_length(2);
      payload.set_streaming_width(2);
      payload.set_byte_enable(mask);
      payload.set_byte_enable_length(0);
      payload.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
      target.expected_payload = payload;
      target.expected_delay = delay_value;

      initiator.b_transport(payload, delay_value);
      payload.get_data(data);
      $display("UT: returned ok %0d data %0h %0h calls %0d", payload.is_response_ok(),
          data[0], data[1], target.calls);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
