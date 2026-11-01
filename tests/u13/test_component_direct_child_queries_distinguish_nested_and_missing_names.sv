/*
:name: test_component_direct_child_queries_distinguish_nested_and_missing_names
:description: direct child membership and handle queries do not search descendant names (IEEE 1800.2-2020 Section 13.1.3.6)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.3.6 13.1.2.1 13.1.3.1 13.1.3.2 13.1.3.3 13.1.3.4 13.1.3.5 13.1.3.7 13.1.3.8 5.3.4.2 F.7.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_direct_child_queries_distinguish_nested_and_missing_names.expected
*/
// Explicit names and handles make hierarchy membership observable. No traversal
// order is imposed, and hierarchy changes occur before each fresh iteration.
module test_component_direct_child_queries_distinguish_nested_and_missing_names;
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

    $display("UT: direct present %0d handle %0d missing %0d", top_node.has_child("left"),
             top_node.get_child("left") == left, !top_node.has_child("absent"));
    $display("UT: nested_not_direct %0d missing_handle %0d", !top_node.has_child("slot") &&
             !top_node.has_child("left.slot"), top_node.get_child("absent") == null);
    $display("UT: local_slots %0d %0d distinct %0d", left.get_child("slot") == left_leaf,
             right.get_child("slot") == right_leaf, left_leaf != right_leaf);

    $finish;
  end
endmodule
