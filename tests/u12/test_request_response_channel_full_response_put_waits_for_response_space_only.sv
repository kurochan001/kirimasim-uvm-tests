/*
:name: test_request_response_channel_full_response_put_waits_for_response_space_only
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
:expected_stdout: @test_request_response_channel_full_response_put_waits_for_response_space_only.expected
*/
// Positive delays establish a blocked caller before opposite-direction traffic.
// Only one caller waits per direction; no simultaneous-winner order is assumed.
module test_request_response_channel_full_response_put_waits_for_response_space_only;
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

      slave.put("first"); master.put(17);
      fork begin slave.put("second"); returned = 1; end join_none
      #1;
      $display("UT: pending %0d response_full %0d request_ready %0d", !returned,
               !slave.can_put(), slave.can_get());
      master.get(response_value);
      $display("UT: first_response %s", response_value);
      wait (returned); master.get(response_value); slave.get(request_value);
      $display("UT: second_response %s request %0d returned %0d", response_value,
               request_value, returned);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #60; $fatal(1, "channel watchdog expired"); end

endmodule
