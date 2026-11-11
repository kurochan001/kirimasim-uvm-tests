/*
:name: test_child_sequence_start_invokes_parent_execution_hooks
:description: child sequence execution invokes parent pre mid and post hooks with child identity (IEEE 1800.2-2020 Section 14.2.3.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.3.1 14.2.3.4 14.2.3.5 14.2.3.6 14.2.3.7 14.1.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_child_sequence_start_invokes_parent_execution_hooks.expected
*/
// What it checks:
// Starting a child sequence invokes its parent pre_do, mid_do and post_do
// around the child body.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.2.3.1 (UVM-SEQUENCE-CHILD-PARENT-HOOKS) gives the rule above.
// Setup: Use explicit child priority and parent/child handles without item
// traffic. Expected: The ordered trace identifies a sequence pre_do and the
// exact child/parent handles.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use an explicit child priority so no priority is inherited from an
// inactive parent. Observe callback order and the exact child handle.

module test_child_sequence_start_invokes_parent_execution_hooks;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class parent_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(parent_sequence)
    uvm_sequence_item expected;
    function new(string name="parent_sequence"); super.new(name); endfunction
    task body(); endtask
    task pre_do(bit is_item); $display("UT: parent_pre is_item %0d", is_item); endtask
    function void mid_do(uvm_sequence_item this_item);
      $display("UT: parent_mid child_same %0d", this_item == expected);
    endfunction
    function void post_do(uvm_sequence_item this_item);
      $display("UT: parent_post child_same %0d", this_item == expected);
    endfunction
  endclass
  class child_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(child_sequence)
    uvm_sequence_base expected_parent;
    function new(string name="child_sequence"); super.new(name); endfunction
    task body(); $display("UT: child_body parent_same %0d",
        get_parent_sequence() == expected_parent); endtask
  endclass
  initial begin
    automatic parent_sequence parent = new("parent");
    automatic child_sequence child = new("child");
    parent.expected = child;
    child.expected_parent = parent;
    child.start(null, parent, 25);
    $finish;
  end
endmodule
