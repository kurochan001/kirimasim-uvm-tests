/*
:name: test_request_response_channel_analysis_ports_publish_accepted_writes
:description: channel request and response analysis ports publish their accepted writes (IEEE 1800.2-2020 Section 12.2.9.1.7)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.1.7 12.2.9.1.8 12.2.9.1.3 12.2.9.1.6 12.2.8.3 12.2.9.1.11 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_request_response_channel_analysis_ports_publish_accepted_writes.expected
*/
// What it checks:
// 1. Accepted request writes are broadcast through the channel request
//    analysis port.
// 2. Accepted response writes are broadcast through the channel response
//    analysis port.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.9.1.7 (UVM-TLM1-CHANNEL-REQUEST-ANALYSIS-NOTIFICATION)
//    gives rule 1 above. Setup: Connect a typed monitor and accept request
//    values 11 then 22. Expected: The request monitor receives exactly two
//    ordered notifications with those values.
// 2. 1800.2-2020 12.2.9.1.8 (UVM-TLM1-CHANNEL-RESPONSE-ANALYSIS-NOTIFICATION)
//    gives rule 2 above. Setup: Connect a typed monitor and accept done1 then
//    done2. Expected: The response monitor receives exactly two ordered
//    notifications with those values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Connect separate typed analysis FIFO monitors. Inspect each monitor
// after write completion, without depending on subscriber call order.

module test_request_response_channel_analysis_ports_publish_accepted_writes;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_req_rsp_channel#(int, string) channel_value;
    uvm_nonblocking_put_port#(int) request_tx;
    uvm_nonblocking_get_peek_port#(int) request_rx;
    uvm_nonblocking_put_port#(string) response_tx;
    uvm_nonblocking_get_peek_port#(string) response_rx;

    uvm_tlm_analysis_fifo#(int) request_monitor;
    uvm_tlm_analysis_fifo#(string) response_monitor;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      channel_value = new("channel_value", this, 2, 2);

      request_tx = new("request_tx", this);
      request_rx = new("request_rx", this);
      response_tx = new("response_tx", this);
      response_rx = new("response_rx", this);

      request_monitor = new("request_monitor", this);
      response_monitor = new("response_monitor", this);

    endfunction
    function void connect_phase(uvm_phase phase);
      request_tx.connect(channel_value.put_request_export);
      request_rx.connect(channel_value.get_peek_request_export);
      response_tx.connect(channel_value.put_response_export);
      response_rx.connect(channel_value.get_peek_response_export);

      channel_value.request_ap.connect(request_monitor.analysis_export);
      channel_value.response_ap.connect(response_monitor.analysis_export);

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

      if (!request_tx.try_put(11)) $fatal(1, "first request rejected");
      if (!request_tx.try_put(22)) $fatal(1, "second request rejected");
      if (!response_tx.try_put("done1")) $fatal(1, "first response rejected");
      if (!response_tx.try_put("done2")) $fatal(1, "second response rejected");
      $display("UT: notification_counts %0d %0d", request_monitor.used(), response_monitor.used());
      if (!request_monitor.try_get(request_value)) $fatal(1, "first request notification missing");
      if (!request_monitor.try_get(next_request)) $fatal(1, "second request notification missing");
      if (!response_monitor.try_get(response_value)) $fatal(1,
          "first response notification missing");
      if (!response_monitor.try_get(next_response)) $fatal(1,
          "second response notification missing");
      $display("UT: request_notifications %0d %0d", request_value, next_request);
      $display("UT: response_notifications %s %s", response_value, next_response);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
