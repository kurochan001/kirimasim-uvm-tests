/*
:name: test_field_op_set_and_flush_change_copy_to_compare
:description: a field operation can be flushed and reconfigured for comparison (IEEE 1800.2-2020 Section 5.7.2.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.2 5.7.2.3 5.7.2.4 5.7.2.5 5.7.2.6 5.7.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_op_set_and_flush_change_copy_to_compare.expected
*/
// What it checks:
// 1. A valid field-operation set associates the selected operation, policy and
//    optional rhs.
// 2. Flush permits a new operation to replace the old descriptor state.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.7.2.2 (UVM-FIELD-OP-SET-ASSOCIATIONS) gives rule 1 above.
//    Setup: Query only after set and flush between operations, including null
//    rhs. Expected: Operation, policy and rhs queries match each newly
//    supplied association.
// 2. 1800.2-2020 5.7.2.9 (UVM-BASE-AUDIT-FIELD-FLUSH-REUSE) gives rule 2
//    above. Setup: Reassess the existing unchanged field-operation fixture and
//    compatible record. Expected: The old copy becomes compare with the newly
//    selected policy/rhs identities.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
    automatic uvm_field_op op = new;
    automatic uvm_copier copier = new;
    automatic uvm_comparer comparer = new;
    automatic item first = new("first");
    automatic item second = new("second");
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
