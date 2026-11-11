/*
:name: test_nonblocking_master_imp_routes_capacity_and_response_peek_to_correct_siblings
:description: nonblocking master imp observes request capacity separately from response availability (IEEE 1800.2-2020 Section 12.2.7.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.7.2.2 12.2.7.2 12.2.3.2 12.2.5.2 12.2.4.2.1 12.2.4.2.2 12.2.4.2.3 12.2.4.2.4 12.2.4.2.6 12.2.4.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_nonblocking_master_imp_routes_capacity_and_response_peek_to_correct_siblings.expected
*/
// What it checks:
// Nonblocking master/slave imps delegate availability and traffic to the
// supplied request/response implementations.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.7.2.2 (UVM-TLM1-SPLIT-NONBLOCKING-IMP-IMPLEMENTATIONS)
// gives the rule above. Setup: Independently fill request/response siblings,
// then peek and get through the imp. Expected: Capacity/rejection and typed
// head values stay with their selected sibling; unavailable reads return
// false.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Fill only the request FIFO and observe response unavailability separately.
// Then provide one response and require peek/get to observe the same value.
// No output argument from a failed read is inspected.

module test_nonblocking_master_imp_routes_capacity_and_response_peek_to_correct_siblings;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class split_endpoint extends uvm_component;
    `uvm_component_utils(split_endpoint)
    uvm_tlm_fifo#(int) requests;
    uvm_tlm_fifo#(string) responses;
    uvm_nonblocking_master_imp#(int, string, split_endpoint,
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
    uvm_nonblocking_master_port#(int, string) port_value;
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
      first_ok = port_value.try_put(21);
      second_ok = port_value.try_put(22);
      $display("UT: accepted %0d rejected %0d request_full %0d response_empty %0d", first_ok,
               !second_ok, !port_value.can_put(), !port_value.can_get());
      endpoint.responses.put("ready");
      peek_ok = port_value.try_peek(response_head);
      get_ok = port_value.try_get(response_value);
      endpoint.requests.get(request_value);
      $display("UT: peek_ok %0d get_ok %0d response %s %s request %0d empty %0d", peek_ok,
               get_ok, response_head, response_value, request_value, !port_value.can_peek());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
