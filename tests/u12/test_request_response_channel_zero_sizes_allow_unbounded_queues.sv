/*
:name: test_request_response_channel_zero_sizes_allow_unbounded_queues
:description: zero request and response sizes select independently unbounded channel queues (IEEE 1800.2-2020 Section 12.2.9.1.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.1.3 12.2.9.1.6 12.2.9.1.4 12.2.9.1.5 12.2.8.2.1 12.2.4.2.5 12.2.9.1.11 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_request_response_channel_zero_sizes_allow_unbounded_queues.expected
*/
// What it checks:
// A zero-sized request FIFO is unbounded.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.8.2.1 (UVM-TLM1-CHANNEL-ZERO-SIZED-REQUEST-FIFO) gives the
// rule above. Setup: Configure both channel queues with size zero and accept
// three requests before retrieval. Expected: Further request puts remain
// possible and the first head is zero with more data available.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Write several entries to both queues before reading. Availability
// remains true and the first values preserve their source order.

module test_request_response_channel_zero_sizes_allow_unbounded_queues;
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
      channel_value = new("channel_value", this, 0, 0);

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

      index = 0;
      repeat (3) begin
        if (!request_tx.try_put(index)) $fatal(1, "request rejected");
        if (!response_tx.try_put($sformatf("r%0d", index))) $fatal(1, "response rejected");
        index++;
      end
      $display("UT: can_put request %0d response %0d", request_tx.can_put(), response_tx.can_put());
      if (!request_rx.try_get(request_value)) $fatal(1, "request missing");
      if (!response_rx.try_get(response_value)) $fatal(1, "response missing");
      $display("UT: heads %0d %s still_available %0d %0d", request_value, response_value,
               request_rx.can_get(), response_rx.can_get());

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
