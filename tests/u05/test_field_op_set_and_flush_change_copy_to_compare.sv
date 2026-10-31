/*
:name: test_field_op_set_and_flush_change_copy_to_compare
:description: a field operation can be flushed and reconfigured for comparison (IEEE 1800.2-2020 Section 5.7.2.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.2 5.7.2.3 5.7.2.4 5.7.2.5 5.7.2.6 5.7.2.9
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_op_set_and_flush_change_copy_to_compare.expected
*/
// Operation names are specified by Table 1. Query only after set, and
// flush before changing the operation, policy and right-hand-side object.

module test_field_op_set_and_flush_change_copy_to_compare;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    uvm_field_op op = new;
    uvm_copier copier = new;
    uvm_comparer comparer = new;
    item first = new("first");
    item second = new("second");
    op.set(UVM_COPY, copier, first);
    $display("UT: first %s type %0d policy %0d rhs %0d", op.get_op_name(),
             op.get_op_type() == UVM_COPY, op.get_policy() == copier, op.get_rhs() == first);
    op.flush();
    op.set(UVM_COMPARE, comparer, second);
    $display("UT: second %s type %0d policy %0d rhs %0d", op.get_op_name(),
             op.get_op_type() == UVM_COMPARE, op.get_policy() == comparer, op.get_rhs() == second);
    $finish;
  end
endmodule
