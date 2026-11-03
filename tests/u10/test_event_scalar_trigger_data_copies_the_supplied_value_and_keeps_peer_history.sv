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
