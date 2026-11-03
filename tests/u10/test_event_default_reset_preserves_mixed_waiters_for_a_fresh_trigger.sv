/*
:name: test_event_default_reset_preserves_mixed_waiters_for_a_fresh_trigger
:description: event default reset preserves mixed waiters for a fresh trigger (IEEE 1800.2-2020 Section 10.1.1.2.10)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.1.2.10 10.1.1.2.2 10.1.1.2.3 10.1.1.2.4 10.1.1.2.5 10.1.1.2.8 10.1.2.2.4 10.1.2.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_default_reset_preserves_mixed_waiters_for_a_fresh_trigger.expected
*/
// Positive delays establish raw-trigger, persistent-trigger and on-state
// waiters plus an independent off-state peer. Default reset does not request
// trigger wakeup. The waiter query still reports blocked processes, and a
// later
// fresh trigger releases them. Bounded observations precede cleanup of any
// stranded process; no implementation event handle is inspected.
module test_event_default_reset_preserves_mixed_waiters_for_a_fresh_trigger;
  import uvm_pkg::*;
  uvm_event#(int) subject,peer;
  process waiting[3];
  bit [2:0] completed = 0;
  bit peer_returned = 0;
  int values[3];
  initial begin
    subject = new("subject"); peer = new("peer"); peer.trigger(71);
    fork
      begin waiting[0] = process::self(); subject.wait_trigger();
        values[0] = subject.get_trigger_data(); completed[0] = 1; end
      begin waiting[1] = process::self(); subject.wait_ptrigger();
        values[1] = subject.get_trigger_data(); completed[1] = 1; end
      begin waiting[2] = process::self(); subject.wait_on();
        values[2] = subject.get_trigger_data(); completed[2] = 1; end
      begin peer.wait_off(); peer_returned = 1; end
    join_none
    #1;
    $display("UT: event_waiter_initial subject %0d peer %0d blocked %0d",
             subject.get_num_waiters(),peer.get_num_waiters(),completed == 0 && !peer_returned);
    subject.reset(); peer.reset(); #1;
    $display("UT: event_waiter_reset subject %0d blocked %0d peer_returned %0d peer_waiters %0d",
             subject.get_num_waiters(),completed == 0,peer_returned,peer.get_num_waiters());
    subject.trigger(33); #1;
    $display("UT: event_waiter_fresh complete %0d data %0d/%0d/%0d waiters %0d",
             completed == 7,values[0],values[1],values[2],subject.get_num_waiters());
    foreach (waiting[i]) if (!completed[i]) waiting[i].kill();
    $finish;
  end
  initial begin #50; $fatal(1,"mixed event waiter watchdog expired"); end
endmodule
