/*
:name: test_component_children_append_preserves_prefix_and_excludes_descendants
:description: get_children appends immediate children without replacing the supplied prefix (IEEE 1800.2-2020 Section 13.1.3.3)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.3.3 13.1.2.1 13.1.3.1 13.1.3.2 13.1.3.4 13.1.3.5 13.1.3.6 13.1.3.7 13.1.3.8 5.3.4.2 F.7.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_children_append_preserves_prefix_and_excludes_descendants.expected
*/
// Explicit names and handles make hierarchy membership observable. No traversal
// order is imposed, and hierarchy changes occur before each fresh iteration.
module test_component_children_append_preserves_prefix_and_excludes_descendants;
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

    uvm_component children[$];
    bit left_seen;
    bit right_seen;
    bit no_other;
    children.push_back(left_leaf);
    top_node.get_children(children);
    left_seen = 0; right_seen = 0; no_other = 1;
    for (int i = 1; i < children.size(); i++) begin
      if (children[i] == left) left_seen = 1;
      else if (children[i] == right) right_seen = 1;
      else no_other = 0;
    end
    $display("UT: size %0d prefix %0d members %0d immediate_only %0d", children.size(),
             children[0] == left_leaf, left_seen && right_seen, no_other);
    $display("UT: counts top %0d left %0d leaf %0d", top_node.get_num_children(),
             left.get_num_children(), left_leaf.get_num_children());

    $finish;
  end
endmodule
