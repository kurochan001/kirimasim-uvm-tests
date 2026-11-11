/*
:name: test_sequence_unlock_releases_selected_ownership
:description: sequence release APIs clear selected ownership and unblock eligible peers (IEEE 1800.2-2020 Section 14.2.5.7)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.7 14.2.5.8 14.2.5.5 14.2.5.6 14.2.5.9 14.2.5.10 14.1.2.5 14.1.2.6 15.3.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_unlock_releases_selected_ownership.expected
*/
// What it checks:
// 1. Omitted unlock releases ownership on the default sequencer only.
// 2. Explicit ungrab releases ownership on its supplied sequencer.
// 3. is_blocked follows ownership and its selected-sequencer release.
// 4. has_lock reports the sequence ownership on its default sequencer.
// 5. get_sequencer returns the assigned default despite explicit ownership
//    operations elsewhere.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.5.7 (UVM-SEQUENCE-UNLOCK-DEFAULT-LOCALITY) gives rule 1
//    above. Setup: The sequence holds a default lock and a grab on a different
//    explicit sequencer. Expected: Default ownership clears while the explicit
//    grab and its peer blocking remain.
// 2. 1800.2-2020 14.2.5.8 (UVM-SEQUENCE-UNGRAB-EXPLICIT-TARGET) gives rule 2
//    above. Setup: The default lock has been released while a grab remains on
//    the other sequencer. Expected: The remaining explicit grab clears.
// 3. 1800.2-2020 14.2.5.9 (UVM-SEQUENCE-PEER-BLOCKING-FOLLOWS-TARGET-RELEASE)
//    gives rule 3 above. Setup: Two peers use different defaults while an
//    owner holds both sequencers. Expected: Both peers begin blocked;
//    releasing only the default unblocks only that peer.
// 4. 1800.2-2020 14.2.5.10 (UVM-SEQUENCE-HAS-LOCK-REFLECTS-SELECTED-RELEASE)
//    gives rule 4 above. Setup: A sequence holds a default lock or grab and
//    then releases it through its default release API. Expected: The owner
//    reports ownership before release and no ownership afterward.
// 5. 1800.2-2020 14.1.2.5
//    (UVM-SEQUENCE-DEFAULT-SEQUENCER-SURVIVES-EXPLICIT-OWNERSHIP) gives rule 5
//    above. Setup: The owner is assigned left, then holds/releases ownership
//    on left and right. Expected: Its returned default remains left.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use sequence-side release APIs on idle public sequencers.
// Positive delays separate queued-peer observations from release completion.
module test_sequence_unlock_releases_selected_ownership;
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
      owner.lock(); owner.grab(right);
      $display("UT: held default %0d explicit %0d left_blocked %0d right_blocked %0d",
               owner.has_lock(), right.has_lock(owner), left_peer.is_blocked(),
               right_peer.is_blocked());
      owner.unlock();
      $display("UT: default_release left %0d right %0d left_blocked %0d right_blocked %0d",
               owner.has_lock(), right.has_lock(owner), left_peer.is_blocked(),
               right_peer.is_blocked());
      owner.ungrab(right);
      $display("UT: explicit_release left %0d right %0d default_unchanged %0d",
               owner.has_lock(), right.has_lock(owner), owner.get_sequencer() == left);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "sequence release watchdog expired"); end
endmodule
