/*
:name: test_transport_channel_reuses_storage_for_sequential_transactions
:description: blocking transport channel pairs two sequential requests with their responses (IEEE 1800.2-2020 Section 12.2.9.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.2.2 12.2.9.2.3 12.2.3.1 12.2.4.2.10 12.2.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transport_channel_reuses_storage_for_sequential_transactions.expected
*/
// Execute transport calls sequentially and let one target serve them.
// The target uses positive delays and each call must return its own response.

module test_transport_channel_reuses_storage_for_sequential_transactions;
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
          initiator.transport(11, first_response);
          initiator.transport(22, second_response);
          returned = 1;
        end
        begin
          request_rx.get(first_request);
          #1;
          response_tx.put("first");
          request_rx.get(second_request);
          #1;
          response_tx.put("second");
        end
      join
      $display("UT: requests %0d %0d responses %s %s returned %0d", first_request, second_request,
               first_response, second_response, returned);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
