/*
:name: test_request_response_channel_capacities_are_independent
:description: request and response FIFO bounds reject writes independently (IEEE 1800.2-2020 Section 12.2.9.1.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.1.3 12.2.9.1.6 12.2.9.1.5 12.2.9.1.4 12.2.4.2.4 12.2.4.2.5 12.2.9.1.11 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_request_response_channel_capacities_are_independent.expected
*/
// What it checks:
// 1. The request export stores accepted requests in its configured FIFO.
// 2. The response export stores accepted responses independently in its
//    configured FIFO.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.9.1.3 (UVM-TLM1-CHANNEL-REQUEST-FIFO-ORDER) gives rule 1
//    above. Setup: Queue two ordered int requests or fill a one-entry request
//    queue. Expected: Reads preserve source order; a full queue rejects an
//    extra request and retains its first value.
// 2. 1800.2-2020 12.2.9.1.6 (UVM-TLM1-CHANNEL-RESPONSE-FIFO-ORDER) gives rule
//    2 above. Setup: Queue two strings and try an extra response at capacity.
//    Expected: Responses retain source order and rejection preserves the
//    existing response head.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Configure one request slot and two response slots. A full request
// queue does not prevent writes to the separate response queue.

module test_request_response_channel_capacities_are_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_req_rsp_channel#(int, string) channel_value;
    uvm_nonblocking_put_port#(int) request_tx;
    uvm_nonblocking_get_peek_port#(int) request_rx;
    uvm_nonblocking_put_port#(string) response_tx;
    uvm_nonblocking_get_peek_port#(string) response_rx;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      channel_value = new("channel_value", this, 1, 2);

      request_tx = new("request_tx", this);
      request_rx = new("request_rx", this);
      response_tx = new("response_tx", this);
      response_rx = new("response_rx", this);

    endfunction
    function void connect_phase(uvm_phase phase);
      request_tx.connect(channel_value.put_request_export);
      request_rx.connect(channel_value.get_peek_request_export);
      response_tx.connect(channel_value.put_response_export);
      response_rx.connect(channel_value.get_peek_response_export);

    endfunction
    task run_phase(uvm_phase phase);
      int request_value;
      int next_request;
      string response_value;
      string next_response;
      bit ok;
      bit second_ok;
      int index;
      phase.raise_objection(this);

      ok = request_tx.try_put(11);
      second_ok = request_tx.try_put(22);
      $display("UT: request_puts %0d %0d available %0d", ok, second_ok, request_tx.can_put());
      ok = response_tx.try_put("a");
      second_ok = response_tx.try_put("b");
      $display("UT: response_puts %0d %0d available %0d", ok, second_ok, response_tx.can_put());
      ok = response_tx.try_put("rejected");
      $display("UT: extra_response %0d", ok);
      if (!request_rx.try_get(request_value)) $fatal(1, "request missing");
      if (!response_rx.try_get(response_value)) $fatal(1, "response missing");
      $display("UT: heads %0d %s space_restored %0d %0d", request_value, response_value,
               request_tx.can_put(), response_tx.can_put());

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
