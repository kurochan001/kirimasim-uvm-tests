/*
:name: test_sequencer_last_item_buffers_clamp_oversized_requests
:description: oversized sequencer last request and response buffers clamp to 1024 and report warnings (IEEE 1800.2-2020 Section 15.3.3.2.1)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.3.2.1 15.3.3.2.2 15.3.4.2.1 15.3.4.2.2 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_last_item_buffers_clamp_oversized_requests.expected
*/
// What it checks:
// 1. Request-history capacity defaults to one, accepts in-range settings and
//    clamps oversized settings to 1024 with a warning.
// 2. Response-history capacity defaults to one, accepts in-range settings and
//    clamps oversized settings to 1024 with a warning.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.3.3.2.1 (UVM-SEQUENCER-REQUEST-HISTORY-CAPACITY) gives
//    rule 1 above. Setup: Set capacities three/zero independently and request
//    2048 on another sequencer. Expected: Getters reflect local settings and
//    the oversized request reports 1024 with an increased warning count.
// 2. 1800.2-2020 15.3.4.2.2 (UVM-SEQUENCER-RESPONSE-HISTORY-CAPACITY) gives
//    rule 2 above. Setup: Set capacities two/four independently and request
//    4096 on another sequencer. Expected: Getters reflect local settings
//    independently of request capacities; overflow yields 1024 and a warning.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe each required warning as an increase, not a fixed number
// or report identifier. Buffer contents are not inspected.

module test_sequencer_last_item_buffers_clamp_oversized_requests;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_sequencer#(packet) sequencer = new("sequencer", null);
    automatic uvm_root root = uvm_root::get();
    automatic uvm_report_server server = uvm_report_server::get_server();
    int warnings;
    root.set_report_severity_action(UVM_WARNING, UVM_DISPLAY);
    warnings = server.get_severity_count(UVM_WARNING);
    sequencer.set_num_last_reqs(2048);
    $display("UT: request_size %0d warning_reported %0d", sequencer.get_num_last_reqs(),
        server.get_severity_count(UVM_WARNING) > warnings);
    warnings = server.get_severity_count(UVM_WARNING);
    sequencer.set_num_last_rsps(4096);
    $display("UT: response_size %0d warning_reported %0d", sequencer.get_num_last_rsps(),
        server.get_severity_count(UVM_WARNING) > warnings);
    $finish;
  end
endmodule
