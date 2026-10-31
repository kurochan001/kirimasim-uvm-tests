/*
:name: test_sequence_parent_chain_determines_automatic_depth
:description: sequence depth follows the assigned parent hierarchy (IEEE 1800.2-2020 Section 14.1.2.9)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.9 14.1.2.7 14.1.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_parent_chain_determines_automatic_depth.expected
*/
// Build the entire parent chain before asking for depth. No explicit
// depth override or sequence execution is involved.

module test_sequence_parent_chain_determines_automatic_depth;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(empty_sequence)
    function new(string name="empty_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  initial begin
    automatic empty_sequence root = new("root");
    automatic empty_sequence child = new("child");
    automatic empty_sequence grandchild = new("grandchild");
    child.set_parent_sequence(root);
    grandchild.set_parent_sequence(child);
    $display("UT: depths %0d %0d %0d", root.get_depth(), child.get_depth(), grandchild.get_depth());
    $display("UT: parents %0d %0d", child.get_parent_sequence() == root,
        grandchild.get_parent_sequence() == child);
    $finish;
  end
endmodule
