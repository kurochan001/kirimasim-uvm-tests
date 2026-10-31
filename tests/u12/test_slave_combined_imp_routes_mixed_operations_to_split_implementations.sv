/*
:name: test_slave_combined_imp_routes_mixed_operations_to_split_implementations
:description: combined slave interface routes mixed blocking and nonblocking calls to split implementations (IEEE 1800.2-2020 Section 12.2.7.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.7.2.2 12.2.7.2 12.2.3.2 12.2.5.2 12.2.4.2.1 12.2.4.2.2 12.2.4.2.3 12.2.4.2.4 12.2.4.2.6 12.2.4.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_slave_combined_imp_routes_mixed_operations_to_split_implementations.expected
*/
// Mix request reads and response writes on one slave interface. Verify
// peek retention and independent storage reuse through sibling implementations.

module test_slave_combined_imp_routes_mixed_operations_to_split_implementations;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class split_endpoint extends uvm_component;
    `uvm_component_utils(split_endpoint)
    uvm_tlm_fifo#(int) requests;
    uvm_tlm_fifo#(string) responses;
    uvm_slave_imp#(int, string, split_endpoint,
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
    uvm_slave_port#(int, string) port_value;
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
      endpoint.requests.put(51);
      port_value.peek(request_head);
      get_ok = port_value.try_get(request_value);
      endpoint.requests.put(52);
      peek_ok = port_value.try_peek(second_request);
      port_value.get(request_head);
      port_value.put("alpha");
      endpoint.responses.get(response_value);
      first_ok = port_value.try_put("beta");
      endpoint.responses.get(second_response);
      $display("UT: requests %0d %0d %0d read %0d peek %0d accepted %0d", request_value,
               second_request, request_head, get_ok, peek_ok, first_ok);
      $display("UT: responses %s %s reusable %0d empty %0d", response_value,
               second_response, port_value.can_put(), !port_value.can_get());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
