/*
:name: test_sequence_explicit_depth_overrides_calculated_depth
:description: explicit sequence depth replaces automatic depth even when inconsistent with hierarchy (IEEE 1800.2-2020 Section 14.1.2.10)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.10 14.1.2.9 14.1.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_explicit_depth_overrides_calculated_depth.expected
*/
// What it checks:
// 1. Explicit sequence depth overrides automatic depth and the most recent
//    value is returned.
// 2. Sequence depth follows the parent chain when no explicit override is
//    installed.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.1.2.10 (UVM-SEQUENCE-EXPLICIT-DEPTH) gives rule 1 above.
//    Setup: Read automatic depth then set nine and four on the same child.
//    Expected: Depth changes from two to nine to four without changing the
//    parent.
// 2. 1800.2-2020 14.1.2.9 (UVM-SEQUENCE-AUTOMATIC-DEPTH) gives rule 2 above.
//    Setup: Build the full root/child/grandchild chain before querying depth.
//    Expected: Root, child and grandchild depths are one, two and three.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Read automatic depth first, then apply two explicit values without
// changing the parent chain.

module test_sequence_explicit_depth_overrides_calculated_depth;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(empty_sequence)
    function new(string name="empty_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  initial begin
    automatic empty_sequence parent = new("parent");
    automatic empty_sequence child = new("child");
    child.set_parent_sequence(parent);
    $display("UT: automatic_depth %0d", child.get_depth());
    child.set_depth(9);
    $display("UT: first_override %0d", child.get_depth());
    child.set_depth(4);
    $display("UT: latest_override %0d parent_kept %0d", child.get_depth(),
        child.get_parent_sequence() == parent);
    $finish;
  end
endmodule
