/*
:name: test_callback_is_enabled_tracks_explicit_changes_invalid_arguments_and_peer_state
:description: callback is enabled tracks explicit changes invalid arguments and peer state (IEEE 1800.2-2020 Section 10.7.1.2.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.1.2.3 10.7.1.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_is_enabled_tracks_explicit_changes_invalid_arguments_and_peer_state.expected
*/
// What it checks:
// is_enabled reports the callback current enabled state independently per
// instance.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.7.1.2.3 (UVM-OBJECTION-CB-REVIEW-CALLBACK-ENABLED-QUERY)
// gives the rule above. Setup: Use explicit zero/one modes on two callbacks,
// then invalid non-toggle arguments and restoration. Expected: Queries follow
// explicit changes, ignore non-toggle arguments and preserve peer state.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Set every initial state explicitly, then query the actual is_enabled API.
// No omitted callback_mode argument or initial-enable guarantee is assumed.
// Callback dispatch and registration are separate conditions.
module test_callback_is_enabled_tracks_explicit_changes_invalid_arguments_and_peer_state;
  import uvm_pkg::*;
  initial begin
    automatic uvm_callback subject = new("subject");
    automatic uvm_callback peer = new("peer");
    void'(subject.callback_mode(1)); void'(peer.callback_mode(0));
    $display("UT: enabled_initial subject %0d peer %0d",subject.is_enabled(),peer.is_enabled());
    void'(subject.callback_mode(0)); void'(peer.callback_mode(1));
    $display("UT: enabled_changed subject %0d peer %0d",subject.is_enabled(),peer.is_enabled());
    void'(subject.callback_mode(7)); void'(peer.callback_mode(-2));
    $display("UT: enabled_invalid subject %0d peer %0d",subject.is_enabled(),peer.is_enabled());
    void'(subject.callback_mode(1));
    $display("UT: enabled_restored subject %0d peer %0d",subject.is_enabled(),peer.is_enabled());
    $finish;
  end
endmodule
