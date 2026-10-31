/*
:name: test_sequence_root_queries_and_path_follow_parent_chain
:description: sequence root queries and dotted paths identify the topmost parent sequence (IEEE 1800.2-2020 Section 14.1.2.12)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.12 14.1.2.13 14.1.2.14 14.1.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_root_queries_and_path_follow_parent_chain.expected
*/
// Use explicit sequence names and query a descendant. The sequencer
// component hierarchy is not part of the sequence path.

module test_sequence_root_queries_and_path_follow_parent_chain;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(empty_sequence)
    function new(string name="empty_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  initial begin
    automatic empty_sequence root = new("root");
    automatic empty_sequence middle = new("middle");
    automatic empty_sequence leaf = new("leaf");
    middle.set_parent_sequence(root);
    leaf.set_parent_sequence(middle);
    $display("UT: root_same %0d root_name %s path %s", leaf.get_root_sequence() == root,
             leaf.get_root_sequence_name(), leaf.get_sequence_path());
    $finish;
  end
endmodule
