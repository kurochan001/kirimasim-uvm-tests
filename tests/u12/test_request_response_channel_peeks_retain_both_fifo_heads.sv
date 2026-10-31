/*
:name: test_request_response_channel_peeks_retain_both_fifo_heads
:description: request and response channel peeks retain their values until get consumes them (IEEE 1800.2-2020 Section 12.2.9.1.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.1.4 12.2.9.1.5 12.2.9.1.3 12.2.9.1.6 12.2.4.2.8 12.2.4.2.6 12.2.9.1.11 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_request_response_channel_peeks_retain_both_fifo_heads.expected
*/
// Observe repeated peeks on both typed interfaces and compare the
// following get values. No internal FIFO handles are inspected.

module test_request_response_channel_peeks_retain_both_fifo_heads;
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
      channel_value = new("channel_value", this, 1, 1);

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

      if (!request_tx.try_put(7)) $fatal(1, "request rejected");
      if (!response_tx.try_put("ok")) $fatal(1, "response rejected");
      if (!request_rx.try_peek(request_value)) $fatal(1, "first request peek failed");
      if (!request_rx.try_peek(next_request)) $fatal(1, "second request peek failed");
      $display("UT: request_peeks %0d %0d available %0d", request_value, next_request,
          request_rx.can_get());
      if (!request_rx.try_get(request_value)) $fatal(1, "request get failed");
      if (!response_rx.try_peek(response_value)) $fatal(1, "first response peek failed");
      if (!response_rx.try_peek(next_response)) $fatal(1, "second response peek failed");
      $display("UT: response_peeks %s %s available %0d", response_value, next_response,
          response_rx.can_get());
      if (!response_rx.try_get(response_value)) $fatal(1, "response get failed");
      $display("UT: consumed %0d %s empty %0d %0d", request_value, response_value,
          !request_rx.can_get(), !response_rx.can_get());

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
