/*
:name: test_sequence_ungrab_releases_selected_ownership
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
:expected_stdout: @test_sequence_ungrab_releases_selected_ownership.expected
*/
// Use sequence-side release APIs on idle public sequencers.
// Positive delays separate queued-peer observations from release completion.
module test_sequence_ungrab_releases_selected_ownership;
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
      owner.grab(); owner.lock(right);
      $display("UT: held default %0d explicit %0d left_blocked %0d right_blocked %0d",
               owner.has_lock(), right.has_lock(owner), left_peer.is_blocked(),
               right_peer.is_blocked());
      owner.ungrab();
      $display("UT: default_release left %0d right %0d left_blocked %0d right_blocked %0d",
               owner.has_lock(), right.has_lock(owner), left_peer.is_blocked(),
               right_peer.is_blocked());
      owner.unlock(right);
      $display("UT: explicit_release left %0d right %0d default_unchanged %0d",
               owner.has_lock(), right.has_lock(owner), owner.get_sequencer() == left);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "sequence release watchdog expired"); end
endmodule
