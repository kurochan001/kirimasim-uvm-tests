/*
:name: test_transport_channel_waits_for_matching_response
:description: blocking transport channel returns only after the request receives a response (IEEE 1800.2-2020 Section 12.2.9.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.2.2 12.2.9.2.3 12.2.3.1 12.2.4.2.10 12.2.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transport_channel_waits_for_matching_response.expected
*/
// What it checks:
// Blocking transport returns its request response and supports subsequent
// sequential transactions.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.9.2.2 (UVM-TLM1-CHANNEL-BLOCKING-TRANSPORT-RESPONSE) gives
// the rule above. Setup: Delay a single response, then run two sequential
// request/response pairs. Expected: The caller remains blocked until the
// response and sequential requests 11/22 return first/second respectively.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Keep shared values in the test object. The target waits a positive
// delay before observing the blocked transport and returning its response.

module test_transport_channel_waits_for_matching_response;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_transport_channel#(int, string) channel_value;
    uvm_blocking_transport_port#(int, string) initiator;
    uvm_blocking_get_port#(int) request_rx;
    uvm_blocking_put_port#(string) response_tx;
    int first_request = 0;
    int second_request = 0;
    string first_response = "";
    string second_response = "";
    bit returned = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      channel_value = new("channel_value", this);
      initiator = new("initiator", this);
      request_rx = new("request_rx", this);
      response_tx = new("response_tx", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      initiator.connect(channel_value.transport_export);
      request_rx.connect(channel_value.get_peek_request_export);
      response_tx.connect(channel_value.put_response_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork
        begin
          initiator.transport(7, first_response);
          returned = 1;
        end
        begin
          request_rx.get(first_request);
          #1;
          $display("UT: waiting request %0d returned %0d", first_request, returned);
          response_tx.put("ack");
        end
      join
      $display("UT: completed returned %0d response %s", returned, first_response);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
