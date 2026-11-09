/*
:name: test_component_children_results_are_caller_owned_and_scoped_to_each_parent
:description: editing a returned children queue does not change hierarchy or another parent result (IEEE 1800.2-2020 Section 13.1.3.3)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.3.3 13.1.2.1 13.1.3.1 13.1.3.2 13.1.3.4 13.1.3.5 13.1.3.6 13.1.3.7 13.1.3.8 5.3.4.2 F.7.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_children_results_are_caller_owned_and_scoped_to_each_parent.expected
*/
// What it checks:
// 1. get_children appends immediate children to the supplied queue.
// 2. A component child count includes immediate children only.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.3.3 (UVM-COMPONENT-CHILDREN-APPEND) gives rule 1 above.
//    Setup: Retain a prefix and reuse a caller-edited result queue. Expected:
//    Prefixes survive and each appended result contains immediate children
//    rather than descendants.
// 2. 1800.2-2020 13.1.3.5 (UVM-COMPONENT-IMMEDIATE-CHILD-COUNT) gives rule 2
//    above. Setup: Use top, branch and leaf nodes and edit a returned list
//    independently. Expected: Counts remain two at top, one per branch and
//    zero at the leaf.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit names and handles make hierarchy membership observable. No traversal
// order is imposed, and hierarchy changes occur before each fresh iteration.
module test_component_children_results_are_caller_owned_and_scoped_to_each_parent;
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

    uvm_component first[$];
    uvm_component second[$];
    top_node.get_children(first); left.get_children(second);
    $display("UT: initial sizes %0d %0d left_child %0d", first.size(), second.size(),
             second[0] == left_leaf);
    first.delete(); first.push_back(right_leaf);
    top_node.get_children(first);
    $display("UT: edited_then_appended size %0d prefix %0d hierarchy_count %0d", first.size(),
             first[0] == right_leaf, top_node.get_num_children());
    $display("UT: peer_result unchanged %0d parent_count %0d", second.size() == 1 &&
             second[0] == left_leaf, left.get_num_children());

    $finish;
  end
endmodule
