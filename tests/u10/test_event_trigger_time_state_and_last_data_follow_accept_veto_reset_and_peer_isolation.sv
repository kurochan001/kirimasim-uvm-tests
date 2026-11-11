/*
:name: test_event_trigger_time_state_and_last_data_follow_accept_veto_reset_and_peer_isolation
:description: event trigger time state and last data follow accept veto reset and peer isolation (IEEE 1800.2-2020 Section 10.1.1.2.6)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.1.2.6 10.1.1.2.7 10.1.1.2.8 10.1.2.2.4 10.1.2.2.5 10.2.2.2 10.2.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_trigger_time_state_and_last_data_follow_accept_veto_reset_and_peer_isolation.expected
*/
// What it checks:
// 1. The trigger-time query reports the latest accepted trigger, or zero
//    initially and after reset.
// 2. The on-state query reflects acceptance since the last reset independently
//    per event.
// 3. A vetoed candidate does not replace data from the last accepted trigger.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.1.1.2.6 (UVM-SYNC-REVIEW-TRIGGER-TIME-HISTORY) gives rule
//    1 above. Setup: Use accepted triggers, a vetoed candidate, selected-event
//    reset and an independently triggered peer. Expected: The veto keeps times
//    two/three, reset changes only the selected time to zero and reacceptance
//    records six.
// 2. 1800.2-2020 10.1.1.2.7 (UVM-SYNC-REVIEW-ON-STATE-HISTORY) gives rule 2
//    above. Setup: Trigger two events, veto a candidate on one, reset only
//    that event and trigger it again. Expected: Accepted events are on, a
//    reset event is off and the untouched peer remains on.
// 3. 1800.2-2020 10.1.2.2.5 (UVM-SYNC-REVIEW-LAST-DATA-VETO-PRESERVATION)
//    gives rule 3 above. Setup: A callback vetoes value twenty-one after
//    accepted value eleven. Expected: The stored data remains eleven while the
//    peer retains thirty-one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use only accepted-trigger data and positive times. A veto is not a trigger
// and reset changes only the selected event. No trigger-data value after reset
// or before the first accepted trigger is constrained. Callback IDs and
// implementation state are not inspected.
module test_event_trigger_time_state_and_last_data_follow_accept_veto_reset_and_peer_isolation;
  import uvm_pkg::*;
  typedef uvm_event#(int) event_type;
  typedef uvm_event_callback#(int) callback_type;
  class veto_probe extends callback_type;
    int pre_calls = 0,post_calls = 0;
    virtual function bit pre_trigger(event_type e,int data);
      pre_calls++; return data == 21;
    endfunction
    virtual function void post_trigger(event_type e,int data); post_calls++; endfunction
  endclass
  initial begin
    automatic event_type subject = new("subject");
    automatic event_type peer = new("peer");
    automatic veto_probe probe = new();
    uvm_callbacks#(event_type,callback_type)::add(subject,probe);
    $display("UT: trigger_initial times %0d/%0d off %0d/%0d",subject.get_trigger_time(),
             peer.get_trigger_time(),!subject.is_on(),!peer.is_on());
    #2; subject.trigger(11); #1; peer.trigger(31); #1; subject.trigger(21);
    $display("UT: trigger_veto times %0d/%0d data %0d/%0d on %0d/%0d callbacks %0d/%0d",
             subject.get_trigger_time(),peer.get_trigger_time(),subject.get_trigger_data(),
             peer.get_trigger_data(),subject.is_on(),peer.is_on(),probe.pre_calls,probe.post_calls);
    #1; subject.reset();
    $display("UT: trigger_reset time %0d off %0d peer_time %0d peer_on %0d callbacks %0d/%0d",
             subject.get_trigger_time(),!subject.is_on(),peer.get_trigger_time(),peer.is_on(),
             probe.pre_calls,probe.post_calls);
    #1; subject.trigger(12);
    $display("UT: trigger_reaccepted time %0d data %0d on %0d peer_time %0d callbacks %0d/%0d",
             subject.get_trigger_time(),subject.get_trigger_data(),subject.is_on(),
             peer.get_trigger_time(),probe.pre_calls,probe.post_calls);
    $finish;
  end
endmodule
