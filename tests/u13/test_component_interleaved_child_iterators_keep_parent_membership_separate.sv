/*
:name: test_component_interleaved_child_iterators_keep_parent_membership_separate
:description: interleaved iteration over different parents retains each parent cursor and membership (IEEE 1800.2-2020 Section 13.1.3.4)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.3.4 13.1.2.1 13.1.3.1 13.1.3.2 13.1.3.3 13.1.3.5 13.1.3.6 13.1.3.7 13.1.3.8 5.3.4.2 F.7.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_interleaved_child_iterators_keep_parent_membership_separate.expected
*/
// Explicit names and handles make hierarchy membership observable. No traversal
// order is imposed, and hierarchy changes occur before each fresh iteration.
module test_component_interleaved_child_iterators_keep_parent_membership_separate;
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

    automatic node extra = new("extra", left);
    string top_name;
    string left_name;
    string top_final;
    string left_final;
    int top_found;
    int left_found;
    int top_count;
    int left_count;
    bit [1:0] top_members;
    bit [1:0] left_members;
    top_count = 0; left_count = 0; top_members = 0; left_members = 0;
    top_found = top_node.get_first_child(top_name); left_found = left.get_first_child(left_name);
    while ((top_found || left_found) && top_count + left_count < 6) begin
      if (top_found) begin
        if (top_node.get_child(top_name) == left) top_members[0] = 1;
        if (top_node.get_child(top_name) == right) top_members[1] = 1;
        top_count++; top_final = top_name; top_found = top_node.get_next_child(top_name);
      end
      if (left_found) begin
        if (left.get_child(left_name) == left_leaf) left_members[0] = 1;
        if (left.get_child(left_name) == extra) left_members[1] = 1;
        left_count++; left_final = left_name; left_found = left.get_next_child(left_name);
      end
    end
    $display("UT: top count %0d members %0h cursor %0d", top_count, top_members,
             top_name == top_final);
    $display("UT: left count %0d members %0h cursor %0d", left_count, left_members,
             left_name == left_final);

    $finish;
  end
endmodule
