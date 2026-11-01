/*
:name: test_component_child_iteration_preserves_empty_and_exhausted_name_cursors
:description: child iteration preserves sentinels for an empty parent and the final name at exhaustion (IEEE 1800.2-2020 Section 13.1.3.4)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.3.4 13.1.2.1 13.1.3.1 13.1.3.2 13.1.3.3 13.1.3.5 13.1.3.6 13.1.3.7 13.1.3.8 5.3.4.2 F.7.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_child_iteration_preserves_empty_and_exhausted_name_cursors.expected
*/
// Explicit names and handles make hierarchy membership observable. No traversal
// order is imposed, and hierarchy changes occur before each fresh iteration.
module test_component_child_iteration_preserves_empty_and_exhausted_name_cursors;
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

    string name_value;
    string final_name;
    int found;
    name_value = "sentinel"; found = left_leaf.get_first_child(name_value);
    $display("UT: empty returned %0d sentinel %0d", found, name_value == "sentinel");
    found = left.get_first_child(name_value);
    $display("UT: singleton returned %0d named %0d handle %0d", found, name_value == "slot",
             left.get_child(name_value) == left_leaf);
    final_name = name_value; found = left.get_next_child(name_value);
    $display("UT: exhausted returned %0d cursor %0d", found, name_value == final_name);

    $finish;
  end
endmodule
