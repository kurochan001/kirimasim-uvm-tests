/*
:name: test_event_scalar_trigger_data_copies_the_supplied_value_and_keeps_peer_history
:description: event scalar trigger data copies the supplied value and keeps peer history (IEEE 1800.2-2020 Section 10.1.2.2.5)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.2.2.5 10.1.2.1 10.1.2.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_scalar_trigger_data_copies_the_supplied_value_and_keeps_peer_history.expected
*/
// What it checks:
// 1. Scalar trigger data preserves the value supplied at the accepted call.
// 2. A later scalar trigger replaces only that event latest data.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.1.2.2.5 (UVM-SYNC-REVIEW-SCALAR-DATA-VALUE-COPY) gives
//    rule 1 above. Setup: Trigger from an integer variable and later change
//    that caller variable. Expected: Current and saved event data remain
//    thirteen while the caller variable becomes twenty-seven.
// 2. 1800.2-2020 10.1.2.2.5 (UVM-SYNC-REVIEW-SCALAR-LATEST-LOCAL-DATA) gives
//    rule 2 above. Setup: Retain a scalar result and independently trigger a
//    peer before triggering a new value. Expected: Current data becomes
//    twenty-seven, saved data stays thirteen and peer data stays seventy-one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Selected integer payloads check value copying and latest accepted data per
// event. No pre-trigger/default contents, type conversion, four-state values
// or
// relative scheduling of concurrent triggers is asserted.
module test_event_scalar_trigger_data_copies_the_supplied_value_and_keeps_peer_history;
  import uvm_pkg::*;
  initial begin
    automatic uvm_event#(int) subject = new("subject");
    automatic uvm_event#(int) peer = new("peer");
    automatic int supplied = 13;
    automatic int saved;
    peer.trigger(71); subject.trigger(supplied); saved = subject.get_trigger_data();
    supplied = 27;
    $display("UT: event_scalar_copied current %0d saved %0d supplied %0d peer %0d",
             subject.get_trigger_data(),saved,supplied,peer.get_trigger_data());
    subject.trigger(supplied);
    $display("UT: event_scalar_latest current %0d saved %0d peer %0d",
             subject.get_trigger_data(),saved,peer.get_trigger_data());
    $finish;
  end
endmodule
