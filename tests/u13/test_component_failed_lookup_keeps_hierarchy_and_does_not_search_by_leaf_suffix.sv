/*
:name: test_component_failed_lookup_keeps_hierarchy_and_does_not_search_by_leaf_suffix
:description: failed lookup returns null without treating a repeated leaf suffix as a global search (IEEE 1800.2-2020 Section 13.1.3.7)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.3.7 13.1.2.1 13.1.3.1 13.1.3.2 13.1.3.3 13.1.3.4 13.1.3.5 13.1.3.6 13.1.3.8 5.3.4.2 F.7.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_failed_lookup_keeps_hierarchy_and_does_not_search_by_leaf_suffix.expected
*/
// Explicit names and handles make hierarchy membership observable. No traversal
// order is imposed, and hierarchy changes occur before each fresh iteration.
module test_component_failed_lookup_keeps_hierarchy_and_does_not_search_by_leaf_suffix;
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

    $display("UT: missing relative %0d nested %0d absolute %0d", top_node.lookup("slot") == null,
             top_node.lookup("left.absent") == null, left.lookup(".absent.slot") == null);
    $display("UT: valid_after_failure %0d %0d", top_node.lookup("left.slot") == left_leaf,
             top_node.lookup("right.slot") == right_leaf);
    $display("UT: unchanged counts %0d %0d %0d", top_node.get_num_children(),
             left.get_num_children(), right.get_num_children());

    $finish;
  end
endmodule
