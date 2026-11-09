/*
:name: test_sequencer_base_printed_recording_query_reports_default_disable_and_peer_state
:description: sequencer base printed recording query reports default disable and peer state
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.23 15.3.2.22 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_base_printed_recording_query_reports_default_disable_and_peer_state.expected
*/
// What it checks:
// The printed is_auto_enabled_recording_enabled API reports enabled and
// disabled base recording state.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.3.2.23 (UVM-SQR-AUDIT-BASE-PRINTED-RECORDING-QUERY) gives the
// rule above. Setup: Use the selected original fixture, declared type
// arguments, public endpoint/base views and linked stage observations.
// Requests satisfy the grant precondition before send_request and response IDs
// are copied from the actual request. Expected: The printed
// is_auto_enabled_recording_enabled API reports enabled and disabled base
// recording state.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequencer_base_printed_recording_query_reports_default_disable_and_peer_state;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class request_item extends uvm_sequence_item;
    `uvm_object_utils(request_item)
    int value=45;
    function new(string name="request"); super.new(name); endfunction
  endclass
  class response_item extends uvm_sequence_item;
    `uvm_object_utils(response_item)
    int value=145;
    function new(string name="response"); super.new(name); endfunction
  endclass
  initial begin
    automatic uvm_sequencer#(request_item,response_item) selected=new("selected",null);
    automatic uvm_sequencer#(request_item,response_item) peer=new("peer",null);
    automatic uvm_sequencer_base view=selected;
    automatic uvm_sequencer_base other=peer;
    $display("UT: printed_recording_default %0d",view.is_auto_enabled_recording_enabled());
    view.disable_auto_item_recording(); view.disable_auto_item_recording();
    $display("UT: printed_recording_disabled %0d peer %0d",
             view.is_auto_enabled_recording_enabled(),other.is_auto_enabled_recording_enabled());
    $finish;
  end
endmodule
