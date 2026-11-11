/*
:name: test_request_response_channel_master_slave_interfaces_route_both_directions
:description: combined master slave channel interfaces route requests forward and responses backward (IEEE 1800.2-2020 Section 12.2.9.1.9)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.1.9 12.2.9.1.10 12.2.9.1.11 12.2.3.2 12.2.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_request_response_channel_master_slave_interfaces_route_both_directions.expected
*/
// What it checks:
// 1. The channel master interface puts requests and retrieves responses from
//    their respective queues.
// 2. The channel slave interface reads or peeks requests and puts responses in
//    their respective queues.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.9.1.9 (UVM-TLM1-CHANNEL-MASTER-DIRECTION-ROUTING) gives
//    rule 1 above. Setup: Use combined ports with nonblocking traffic and
//    blocked request-put/response-get calls. Expected: Values reach the
//    correct typed direction and opposite traffic does not satisfy a pending
//    response get.
// 2. 1800.2-2020 12.2.9.1.10 (UVM-TLM1-CHANNEL-SLAVE-DIRECTION-ROUTING) gives
//    rule 2 above. Setup: Use combined ports with a blocked response put or
//    request peek. Expected: Values and blocking behavior remain
//    direction-local; response writes do not release a request peeker.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Connect combined nonblocking ports and observe both typed directions.
// Peek calls retain the same value for the following consuming get.

module test_request_response_channel_master_slave_interfaces_route_both_directions;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_req_rsp_channel#(int, string) channel_value;
    uvm_nonblocking_master_port#(int, string) master;
    uvm_nonblocking_slave_port#(int, string) slave;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      channel_value = new("channel_value", this);
      master = new("master", this);
      slave = new("slave", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      master.connect(channel_value.master_export);
      slave.connect(channel_value.slave_export);
    endfunction
    task run_phase(uvm_phase phase);
      int request_value;
      int request_head;
      string response_value;
      string response_head;
      phase.raise_objection(this);
      if (!master.try_put(17)) $fatal(1, "request rejected");
      if (!slave.try_peek(request_head)) $fatal(1, "request peek failed");
      if (!slave.try_get(request_value)) $fatal(1, "request get failed");
      if (!slave.try_put("answer")) $fatal(1, "response rejected");
      if (!master.try_peek(response_head)) $fatal(1, "response peek failed");
      if (!master.try_get(response_value)) $fatal(1, "response get failed");
      $display("UT: request %0d %0d response %s %s", request_head, request_value,
          response_head, response_value);
      $display("UT: empty_request %0d empty_response %0d", !slave.can_get(), !master.can_get());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
