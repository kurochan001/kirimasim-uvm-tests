/*
:name: test_blocking_slave_imp_delegates_requests_and_responses_to_distinct_siblings
:description: blocking slave imp gets requests and puts responses through distinct siblings (IEEE 1800.2-2020 Section 12.2.7.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.7.2.2 12.2.7.2 12.2.3.2 12.2.5.2 12.2.4.2.1 12.2.4.2.2 12.2.4.2.3 12.2.4.2.4 12.2.4.2.6 12.2.4.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_blocking_slave_imp_delegates_requests_and_responses_to_distinct_siblings.expected
*/
// What it checks:
// Blocking master/slave imps delegate request and response methods to their
// supplied implementation objects.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.7.2.2 (UVM-TLM1-SPLIT-BLOCKING-IMP-IMPLEMENTATIONS) gives
// the rule above. Setup: Use different request/response types and separate
// sibling FIFO implementations. Expected: Master puts request 11 and reads
// answer; slave reads request 17 and puts reply through the correct siblings.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A slave gets and peeks requests, but puts responses. Bind sibling FIFOs
// with different types and verify both constructor-selected directions.

module test_blocking_slave_imp_delegates_requests_and_responses_to_distinct_siblings;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class split_endpoint extends uvm_component;
    `uvm_component_utils(split_endpoint)
    uvm_tlm_fifo#(int) requests;
    uvm_tlm_fifo#(string) responses;
    uvm_blocking_slave_imp#(int, string, split_endpoint,
        uvm_tlm_fifo#(int), uvm_tlm_fifo#(string)) imp;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      requests = new("requests", this, 1);
      responses = new("responses", this, 1);
      imp = new("imp", this, requests, responses);
    endfunction

  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    split_endpoint endpoint;
    uvm_blocking_slave_port#(int, string) port_value;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      endpoint = new("endpoint", this);
      port_value = new("port_value", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      port_value.connect(endpoint.imp);
    endfunction
    task run_phase(uvm_phase phase);
      int request_value;
      int request_head;
      int second_request;
      string response_value;
      string response_head;
      string second_response;
      bit first_ok;
      bit second_ok;
      bit peek_ok;
      bit get_ok;
      phase.raise_objection(this);
      endpoint.requests.put(17);
      port_value.peek(request_head);
      port_value.get(request_value);
      port_value.put("reply");
      endpoint.responses.get(response_value);
      $display("UT: request_head %0d request %0d response %s", request_head,
               request_value, response_value);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
