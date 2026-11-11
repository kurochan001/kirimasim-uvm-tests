/*
:name: test_sequence_cross_release_releases_selected_ownership
:description: sequence release APIs clear selected ownership and unblock eligible peers (IEEE 1800.2-2020 Section 14.2.5.8)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.8 14.2.5.7 14.2.5.5 14.2.5.6 14.2.5.9 14.2.5.10 14.1.2.5 14.1.2.6 15.3.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_cross_release_releases_selected_ownership.expected
*/
// What it checks:
// 1. ungrab also releases a lock and lets an eligible pending lock complete.
// 2. unlock also releases a grab and lets an eligible pending grab complete.
// 3. A pending peer is blocked while another sequence retains lock or grab
//    ownership.
// 4. After the peer releases its acquired ownership, both sequences report no
//    default lock.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.5.8 (UVM-SEQUENCE-UNGRAB-RELEASES-LOCK-WAITER) gives
//    rule 1 above. Setup: A peer lock call waits while another sequence owns a
//    lock on the same sequencer. Expected: After owner ungrab, the peer call
//    returns and the peer owns the lock.
// 2. 1800.2-2020 14.2.5.7 (UVM-SEQUENCE-UNLOCK-RELEASES-GRAB-WAITER) gives
//    rule 2 above. Setup: A peer grab call waits while another sequence owns a
//    grab on the same sequencer. Expected: After owner unlock, the peer call
//    returns and the peer owns the grab.
// 3. 1800.2-2020 14.2.5.9
//    (UVM-SEQUENCE-PENDING-PEER-IS-BLOCKED-BY-LOCK-OR-GRAB) gives rule 3
//    above. Setup: The peer enters a lock/grab request while an owner has
//    matching ownership. Expected: The peer call has not returned and
//    is_blocked is true before release.
// 4. 1800.2-2020 14.2.5.10 (UVM-SEQUENCE-CROSS-RELEASE-CLEAN-FINAL-OWNERSHIP)
//    gives rule 4 above. Setup: A peer acquires after each cross-release and
//    releases its final grab. Expected: Neither sequence has a lock and the
//    peer is not blocked.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use sequence-side release APIs on idle public sequencers.
// Positive delays separate queued-peer observations from release completion.
module test_sequence_cross_release_releases_selected_ownership;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class idle_sequence extends uvm_sequence#(uvm_sequence_item);
    function new(string name="idle_sequence"); super.new(name); endfunction
    virtual task body(); endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(uvm_sequence_item) left, right;
    idle_sequence owner, left_peer, right_peer;
    bit granted = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      left = new("left", this); right = new("right", this);
      owner = new("owner"); left_peer = new("left_peer"); right_peer = new("right_peer");
      owner.set_sequencer(left); left_peer.set_sequencer(left); right_peer.set_sequencer(right);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      owner.lock();
      fork
        begin left_peer.lock(); granted = 1; end
      join_none
      #2;
      $display("UT: lock_wait granted %0d blocked %0d", granted, left_peer.is_blocked());
      owner.ungrab(); #2;
      $display("UT: ungrab_releases_lock granted %0d peer_owner %0d former_owner %0d",
               granted, left_peer.has_lock(), owner.has_lock());
      left_peer.unlock(); granted = 0;
      owner.grab();
      fork
        begin left_peer.grab(); granted = 1; end
      join_none
      #2;
      $display("UT: grab_wait granted %0d blocked %0d", granted, left_peer.is_blocked());
      owner.unlock(); #2;
      $display("UT: unlock_releases_grab granted %0d peer_owner %0d former_owner %0d",
               granted, left_peer.has_lock(), owner.has_lock());
      left_peer.ungrab();
      $display("UT: cleared owner %0d peer %0d blocked %0d", owner.has_lock(),
               left_peer.has_lock(), left_peer.is_blocked());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "sequence release watchdog expired"); end
endmodule
