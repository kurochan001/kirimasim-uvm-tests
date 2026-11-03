/*
:name: test_transport_channel_fixed_request_and_response_slots_recover_independently
:description: transport channel fixed request and response slots recover independently (IEEE 1800.2-2020 Section 12.2.9.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.2 12.2.9.2.1 12.2.9.2.3 12.2.9.1.3 12.2.9.1.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transport_channel_fixed_request_and_response_slots_recover_independently.expected
*/
// Bind real public channel interfaces with omitted FIFO size arguments.
// Both directions accept one entry, reject a second and recover independently.
// No response pairing, arbitration winner or transport call is inferred.
module test_transport_channel_fixed_request_and_response_slots_recover_independently;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_transport_channel#() channel_value;
    uvm_nonblocking_put_port#(int) request_tx,response_tx;
    uvm_nonblocking_get_port#(int) request_rx,response_rx;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      channel_value = new("channel_value",this);
      request_tx = new("request_tx",this); response_tx = new("response_tx",this);
      request_rx = new("request_rx",this); response_rx = new("response_rx",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      request_tx.connect(channel_value.put_request_export);
      response_tx.connect(channel_value.put_response_export);
      request_rx.connect(channel_value.get_peek_request_export);
      response_rx.connect(channel_value.get_peek_response_export);
    endfunction
    task run_phase(uvm_phase phase);
      bit accepted_request,accepted_response,rejected_request,rejected_response;
      int request_value,response_value;
      phase.raise_objection(this);
      accepted_request = request_tx.try_put(13); accepted_response = response_tx.try_put(27);
      rejected_request = !request_tx.try_put(41); rejected_response = !response_tx.try_put(55);
      $display("UT: capacity_one accepted %0d rejected %0d request_full %0d response_full %0d",
               accepted_request && accepted_response,rejected_request && rejected_response,
               !request_tx.can_put(),!response_tx.can_put());
      if (!request_rx.try_get(request_value)) $fatal(1,"request missing");
      $display("UT: request_removed value %0d request_space %0d response_full %0d",
               request_value,request_tx.can_put(),!response_tx.can_put());
      if (!response_rx.try_get(response_value)) $fatal(1,"response missing");
      $display("UT: response_removed value %0d response_space %0d both_empty %0d",
               response_value,response_tx.can_put(),
               !request_rx.can_get() && !response_rx.can_get());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #60; $fatal(1,"capacity watchdog expired"); end
endmodule
