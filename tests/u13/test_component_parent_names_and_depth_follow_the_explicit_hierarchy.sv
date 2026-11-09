/*
:name: test_component_parent_names_and_depth_follow_the_explicit_hierarchy
:description: component full names, parents and depths follow the same explicit hierarchy (IEEE 1800.2-2020 Section 13.1.3.2)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.3.2 13.1.2.1 13.1.3.1 13.1.3.3 13.1.3.4 13.1.3.5 13.1.3.6 13.1.3.7 13.1.3.8 5.3.4.2 F.7.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_parent_names_and_depth_follow_the_explicit_hierarchy.expected
*/
// What it checks:
// 1. A component parent query returns its actual hierarchy parent.
// 2. A component full name composes its parent path and local name with dots.
// 3. Component depth counts levels from the implicit root at depth zero.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.3.1 (UVM-COMPONENT-PARENT-HANDLE) gives rule 1 above.
//    Setup: Create two branches with identically named leaves. Expected: Each
//    branch and leaf returns the configured parent handle.
// 2. 1800.2-2020 13.1.3.2 (UVM-COMPONENT-FULL-NAME) gives rule 2 above. Setup:
//    Use top, left/right branches and repeated slot leaf names. Expected: Full
//    names include the parent chain and distinguish the equal local leaf
//    names.
// 3. 1800.2-2020 13.1.3.8 (UVM-COMPONENT-HIERARCHY-DEPTH) gives rule 3 above.
//    Setup: Inspect root, top, branch and leaf nodes. Expected: The observed
//    depths are zero, one, two and three.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit names and handles make hierarchy membership observable. No traversal
// order is imposed, and hierarchy changes occur before each fresh iteration.
module test_component_parent_names_and_depth_follow_the_explicit_hierarchy;
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

    $display("UT: names %s %s %s", top_node.get_full_name(), left.get_full_name(),
             left_leaf.get_full_name());
    $display("UT: parents %0d %0d %0d", left.get_parent() == top_node,
             left_leaf.get_parent() == left, right_leaf.get_parent() == right);
    $display("UT: depths %0d %0d %0d %0d", uvm_root::get().get_depth(), top_node.get_depth(),
             left.get_depth(), left_leaf.get_depth());
    $display("UT: same_leaf_names %0d distinct_full_names %0d", left_leaf.get_name() == "slot" &&
             right_leaf.get_name() == "slot",
             left_leaf.get_full_name() != right_leaf.get_full_name());

    $finish;
  end
endmodule
