/*
:name: test_sequence_kill_of_queued_lock_preserves_another_waiter
:description: canceling one queued lock leaves another waiter able to send an item (IEEE 1800.2-2020 Section 14.2.5.11)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.11 14.2.5.5 14.2.5.6 14.2.5.7 14.2.5.8 15.3.2.8 15.3.2.9 15.3.2.15 15.3.2.16 15.5.2.3 15.5.2.5 14.2.3.1 14.2.6.2 14.2.6.3 F.2.4.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_kill_of_queued_lock_preserves_another_waiter.expected
*/
// What it checks:
// 1. Sequence kill removes its pending lock/grab requests from the default
//    sequencer.
// 2. Killing one pending sequence leaves another sequence ownership request
//    intact.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.5.11 (UVM-SEQUENCE-KILL-PENDING-OWNERSHIP) gives rule 1
//    above. Setup: Hold ownership, arm a blocked waiter, kill it before grant,
//    then permit an actual transfer. Expected: The killed waiter stays STOPPED
//    without acquiring; a fresh or surviving request completes.
// 2. 1800.2-2020 14.2.5.11 (UVM-SEQUENCE-KILL-PENDING-SCOPE) gives rule 2
//    above. Setup: Two independent lock waiters block behind an owner before
//    one is killed. Expected: The surviving waiter acquires after release and
//    delivers payload 66.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Hold ownership before starting waiters. Positive delays prove they remain
// blocked before cancellation. A real fresh transfer tests queue cleanup;
// the fixture never inspects a sequencer's private arbitration queue.
module test_sequence_kill_of_queued_lock_preserves_another_waiter;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 66;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class queue_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(queue_sequence)
    bit hold_owner = 0;
    bit use_grab = 0;
    bit entered = 0;
    bit acquired = 0;
    bit release_owner = 0;
    bit finished = 0;
    function new(string name="queue_sequence"); super.new(name); endfunction
    task body();
      packet item;
      entered = 1;
      if (use_grab) grab();
      else lock();
      acquired = 1;
      if (hold_owner) wait (release_owner);
      else begin
        item = new("request");
        start_item(item);
        finish_item(item);
      end
      if (use_grab) ungrab();
      else unlock();
      finished = 1;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    queue_sequence owner;
    queue_sequence canceled;
    queue_sequence survivor;
    packet received;
    bit canceled_returned = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      owner = new("owner");
      canceled = new("canceled");
      survivor = new("survivor");
      owner.hold_owner = 1;

    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork owner.start(sequencer); join_none
      wait (owner.acquired);
      fork begin canceled.start(sequencer); canceled_returned = 1; end join_none
      #1;
      fork survivor.start(sequencer); join_none
      #1;
      $display("UT: peer_waiting %0d peer_acquired %0d", survivor.entered, survivor.acquired);
      $display("UT: waiting %0d acquired %0d owner_held %0d", canceled.entered,
               canceled.acquired, sequencer.has_lock(owner));
      canceled.kill();
      #1;
      owner.release_owner = 1;
      wait (owner.finished);
      fork
        #1;
        begin
          driver.seq_item_port.get_next_item(received);
          if (received == null) $fatal(1, "fresh transfer missing");
          #1;
          driver.seq_item_port.item_done();
        end
      join
      wait (survivor.finished);
      #1;
      $display("UT: stopped %0d acquired %0d returned %0d",
               canceled.get_sequence_state() == UVM_STOPPED, canceled.acquired, canceled_returned);
      $display("UT: survivor %0d payload %0d ownership_clear %0d", survivor.finished,
               received.payload, !sequencer.is_grabbed() && sequencer.current_grabber() == null);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "queued ownership watchdog expired"); end
endmodule
