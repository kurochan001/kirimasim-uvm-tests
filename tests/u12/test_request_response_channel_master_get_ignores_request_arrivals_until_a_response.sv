/*
:name: test_request_response_channel_master_get_ignores_request_arrivals_until_a_response
:description: request and response directions keep blocking completion and stored data independent (IEEE 1800.2-2020 Section 12.2.9.1.9)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.1.9 12.2.9.1.11 12.2.3.1 12.2.3.2 12.2.4.2.1 12.2.4.2.2 12.2.4.2.3 12.2.4.2.5 12.2.4.2.7 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_request_response_channel_master_get_ignores_request_arrivals_until_a_response.expected
*/
// What it checks:
// 1. The channel master interface puts requests and retrieves responses from
//    their respective queues.
// 2. A response get blocks until a response becomes available.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.9.1.9 (UVM-TLM1-CHANNEL-MASTER-DIRECTION-ROUTING) gives
//    rule 1 above. Setup: Use combined ports with nonblocking traffic and
//    blocked request-put/response-get calls. Expected: Values reach the
//    correct typed direction and opposite traffic does not satisfy a pending
//    response get.
// 2. 1800.2-2020 12.2.4.2.2 (UVM-TLM1-CHANNEL-BLOCKED-RESPONSE-GET) gives rule
//    2 above. Setup: Start a master get, provide only a request, then write
//    its response. Expected: The get remains pending after the request and
//    returns answer only after the response write.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive delays establish a blocked caller before opposite-direction traffic.
// Only one caller waits per direction; no simultaneous-winner order is assumed.
module test_request_response_channel_master_get_ignores_request_arrivals_until_a_response;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_req_rsp_channel#(int, string) channel_value;
    uvm_master_port#(int, string) master;
    uvm_slave_port#(int, string) slave;
    int request_value;
    int request_peek;
    string response_value;
    bit returned = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      channel_value = new("channel_value", this, 1, 1);
      master = new("master", this); slave = new("slave", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      master.connect(channel_value.master_export); slave.connect(channel_value.slave_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      fork begin master.get(response_value); returned = 1; end join_none
      #1; master.put(17); #1;
      $display("UT: wrong_direction blocked %0d request_ready %0d", !returned, slave.can_get());
      slave.put("answer"); wait (returned); slave.get(request_value);
      $display("UT: response %s request %0d returned %0d", response_value, request_value, returned);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #60; $fatal(1, "channel watchdog expired"); end

endmodule
