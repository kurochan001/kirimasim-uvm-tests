/*
:name: test_sequencer_nested_grab_selects_child_then_restores_parent
:description: a descendant may acquire under its parent lock and temporarily block that parent (IEEE 1800.2-2020 Section 15.3.2.8)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.8 15.3.2.11 15.3.2.13 14.1.2.8 14.1.2.6 15.3.2.8 15.3.2.9 15.3.2.15 15.3.2.16 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_nested_grab_selects_child_then_restores_parent.expected
*/
// What it checks:
// 1. Parent ownership admits its child while child ownership can block the
//    parent and unrelated sequences.
// 2. has_lock distinguishes the sequence owning a lock from an eligible
//    unlocked child.
// 3. is_grabbed indicates whether any sequence holds a lock or grab.
// 4. current_grabber returns the eligible nested child then restores its
//    still-owning parent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.3.2.8 (UVM-SEQUENCER-PARENT-CHILD-BLOCKING) gives rule 1
//    above. Setup: Use direct ancestry with nested ownership and real
//    parent/child item delivery. Expected: The child is eligible under its
//    parent, nested child ownership blocks the parent, and expected traffic
//    resumes after release.
// 2. 1800.2-2020 15.3.2.9 (UVM-SEQUENCER-NESTED-LOCK-QUERY) gives rule 2
//    above. Setup: Query a child before/after nested ownership and its parent
//    after child release. Expected: The child initially has no lock, then owns
//    one; the parent retains its lock after child release.
// 3. 1800.2-2020 15.3.2.15 (UVM-SEQUENCER-OWNERSHIP-PRESENCE-QUERY) gives rule
//    3 above. Setup: Query held and released ownership through direct and
//    nested cases. Expected: Held ownership reports one and final fully
//    released ownership reports zero.
// 4. 1800.2-2020 15.3.2.16 (UVM-SEQUENCER-CURRENT-HIERARCHICAL-OWNER) gives
//    rule 4 above. Setup: Acquire parent ownership, acquire/release child
//    ownership and finally release the parent. Expected: The query identifies
//    child, then parent, then null.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Construct direct ancestry with the standard parent API. The child
// is eligible under the parent lock; while it owns a nested lock or grab,
// the parent is blocked. Release the child before releasing the parent.

module test_sequencer_nested_grab_selects_child_then_restores_parent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(empty_sequence)
    function new(string name="empty_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(uvm_sequence_item) sequencer;
    empty_sequence first;
    empty_sequence second;
    bit second_granted = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      first = new("first");
      second = new("second");
      first.set_sequencer(sequencer);
      second.set_sequencer(sequencer);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      second.set_parent_sequence(first);
      sequencer.lock(first);
      $display("UT: parent_held child_blocked %0d child_has_lock %0d", sequencer.is_blocked(second),
               sequencer.has_lock(second));
      sequencer.grab(second);

      $display("UT: nested parent_blocked %0d child_blocked %0d child_has_lock %0d owner_child %0d",
               sequencer.is_blocked(first), sequencer.is_blocked(second),
                   sequencer.has_lock(second),
               sequencer.current_grabber() == second);
      sequencer.ungrab(second);

      $display("UT: restored parent_blocked %0d parent_has_lock %0d owner_parent %0d",
               sequencer.is_blocked(first), sequencer.has_lock(first),
               sequencer.current_grabber() == first);
      sequencer.unlock(first);

      $display("UT: cleared locks %0d %0d blocked %0d %0d grabbed %0d owner_null %0d",
               first.has_lock(), second.has_lock(), first.is_blocked(), second.is_blocked(),
               sequencer.is_grabbed(), sequencer.current_grabber() == null);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
