/*
:name: test_field_op_set_preserves_null_rhs
:description: field operations without a right-hand side retain a null rhs (IEEE 1800.2-2020 Section 5.7.2.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.2 5.7.2.3 5.7.2.4 5.7.2.5 5.7.2.6 5.7.2.9
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_op_set_preserves_null_rhs.expected
*/
// Print and unpack can carry their selected policies without an rhs.
// Flush separates the two operations and removes the preceding association.

module test_field_op_set_preserves_null_rhs;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    uvm_field_op op = new;
    uvm_table_printer printer = new;
    uvm_packer packer = new;
    op.set(UVM_PRINT, printer);
    $display("UT: first %s type %0d policy %0d null rhs %0d", op.get_op_name(),
             op.get_op_type() == UVM_PRINT, op.get_policy() == printer, op.get_rhs() == null);
    op.flush();
    op.set(UVM_UNPACK, packer);
    $display("UT: second %s type %0d policy %0d null rhs %0d", op.get_op_name(),
             op.get_op_type() == UVM_UNPACK, op.get_policy() == packer, op.get_rhs() == null);
    $finish;
  end
endmodule
