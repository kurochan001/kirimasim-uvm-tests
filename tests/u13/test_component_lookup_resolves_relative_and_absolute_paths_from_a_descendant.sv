/*
:name: test_component_lookup_resolves_relative_and_absolute_paths_from_a_descendant
:description: component lookup uses local hierarchy for relative paths and the root for leading-dot paths (IEEE 1800.2-2020 Section 13.1.3.7)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.3.7 13.1.2.1 13.1.3.1 13.1.3.2 13.1.3.3 13.1.3.4 13.1.3.5 13.1.3.6 13.1.3.8 5.3.4.2 F.7.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_lookup_resolves_relative_and_absolute_paths_from_a_descendant.expected
*/
// What it checks:
// 1. Component relative lookup starts at the receiver component.
// 2. A leading-dot lookup starts at the implicit hierarchy root.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.3.7 (UVM-COMPONENT-RELATIVE-LOOKUP) gives rule 1 above.
//    Setup: Query a local slot and a nested branch path with no leading dot.
//    Expected: Each query returns the intended descendant of its own receiver.
// 2. 1800.2-2020 13.1.3.7 (UVM-COMPONENT-ABSOLUTE-LOOKUP) gives rule 2 above.
//    Setup: Perform cross-branch absolute lookups from a branch and a leaf.
//    Expected: Both absolute paths return the named leaf independent of the
//    calling branch.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit names and handles make hierarchy membership observable. No traversal
// order is imposed, and hierarchy changes occur before each fresh iteration.
module test_component_lookup_resolves_relative_and_absolute_paths_from_a_descendant;
  import uvm_pkg::*;
  class node extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  initial begin
    automatic node top_node = new("top", null);
    automatic node left = new("left", top_node);
    automatic node right = new("right", top_node);
    automatic node left_leaf = new("slot", left);
    automatic node right_leaf = new("slot", right);

    $display("UT: relative parent %0d nested %0d", left.lookup("slot") == left_leaf,
             top_node.lookup("left.slot") == left_leaf);
    $display("UT: absolute cross_branch %0d root_path %0d", left_leaf.lookup(".top.right.slot") ==
             right_leaf, right.lookup(".top.left.slot") == left_leaf);
    $display("UT: own_branch %0d peer_branch %0d", left.lookup("slot") == left_leaf,
             right.lookup("slot") == right_leaf);

    $finish;
  end
endmodule
