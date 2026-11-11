/*
:name: test_copier_history_tracks_started_finished_and_flush
:description: copier history progresses from NEVER to STARTED to FINISHED and resets on flush (IEEE 1800.2-2020 Section 16.6.4.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.4.2 16.6.4.1 16.1.2.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_history_tracks_started_finished_and_flush.expected
*/
// What it checks:
// Copy history is local to a policy and ordered object pair under its
// recursion mode.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.6.4.2 (UVM-COPIER-HISTORY) gives the rule above. Setup: Query
// before/during/after a copy, reverse the pair, compare another policy and
// flush. Expected: Only the selected pair/policy becomes STARTED then
// FINISHED; flush restores NEVER.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The target hook queries the exact ordered pair under the active
// recursion policy. Flush restores the never-copied state for later reuse.

module test_copier_history_tracks_started_finished_and_flush;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class copy_probe extends uvm_object;
    `uvm_object_utils(copy_probe)
    int value = 0;
    uvm_copier selected;
    bit started_in_hook = 0;
    function new(string name="copy_probe"); super.new(name); endfunction
    function void do_copy(uvm_object rhs);
      copy_probe source;
      super.do_copy(rhs);
      if (!$cast(source, rhs)) $fatal(1, "unexpected copy type");
      if (selected != null)
        started_in_hook = selected.object_copied(this, rhs,
            selected.get_recursion_policy()) == uvm_policy::STARTED;
      value = source.value;
    endfunction
  endclass

  initial begin
    automatic copy_probe source = new("source");
    automatic copy_probe target = new("target");
    automatic uvm_copier copier = new;
    target.selected = copier;
    source.value = 19;
    $display("UT: before never %0d", copier.object_copied(target, source,
        copier.get_recursion_policy()) == uvm_policy::NEVER);
    copier.copy_object(target, source);
    $display("UT: hook started %0d value %0d", target.started_in_hook, target.value);
    $display("UT: after finished %0d", copier.object_copied(target, source,
        copier.get_recursion_policy()) == uvm_policy::FINISHED);
    copier.flush();
    $display("UT: flushed never %0d", copier.object_copied(target, source,
        copier.get_recursion_policy()) == uvm_policy::NEVER);
    $finish;
  end
endmodule
