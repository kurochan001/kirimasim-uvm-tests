/*
:name: test_request_response_channel_slave_peek_waits_for_a_request_and_preserves_its_head
:description: request and response directions keep blocking completion and stored data independent (IEEE 1800.2-2020 Section 12.2.9.1.10)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.1.10 12.2.9.1.11 12.2.3.1 12.2.3.2 12.2.4.2.1 12.2.4.2.2 12.2.4.2.3 12.2.4.2.5 12.2.4.2.7 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_request_response_channel_slave_peek_waits_for_a_request_and_preserves_its_head.expected
*/
// What it checks:
// 1. The channel slave interface reads or peeks requests and puts responses in
//    their respective queues.
// 2. A request peek blocks until a request exists and leaves that request
//    available.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.9.1.10 (UVM-TLM1-CHANNEL-SLAVE-DIRECTION-ROUTING) gives
//    rule 1 above. Setup: Use combined ports with a blocked response put or
//    request peek. Expected: Values and blocking behavior remain
//    direction-local; response writes do not release a request peeker.
// 2. 1800.2-2020 12.2.4.2.3 (UVM-TLM1-CHANNEL-BLOCKED-REQUEST-PEEK) gives rule
//    2 above. Setup: Start a slave peek, provide only a response, then put
//    request 42 and get it afterwards. Expected: Opposite traffic does not
//    release the peek; peek/get both return 42 and the queues finally drain.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive delays establish a blocked caller before opposite-direction traffic.
// Only one caller waits per direction; no simultaneous-winner order is assumed.
module test_request_response_channel_slave_peek_waits_for_a_request_and_preserves_its_head;
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

      fork begin slave.peek(request_peek); returned = 1; end join_none
      #1; slave.put("held"); #1;
      $display("UT: wrong_direction blocked %0d response_ready %0d", !returned, master.can_get());
      master.put(42); wait (returned);
      $display("UT: peek %0d retained %0d", request_peek, slave.can_get());
      slave.get(request_value); master.get(response_value);
      $display("UT: request %0d response %s drained %0d", request_value, response_value,
               !slave.can_get() && !master.can_get());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #60; $fatal(1, "channel watchdog expired"); end

endmodule
