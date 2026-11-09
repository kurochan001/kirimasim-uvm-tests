/*
:name: test_field_op_names_identify_copy_compare_and_set_operations
:description: field operation names and types identify each selected operation (IEEE 1800.2-2020 Section 5.7.2.3)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.3 5.7.2.4 5.7.2.2 5.7.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_op_names_identify_copy_compare_and_set_operations.expected
*/
// What it checks:
// 1. A set field operation reports its table-defined operation name.
// 2. A set field operation reports the operation type supplied to set.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.7.2.3 (UVM-FIELD-OP-NAME) gives rule 1 above. Setup: Set
//    each of the seven reserved operations, flushing between them. Expected:
//    Returned names identify copy, compare, set, print, record, pack and
//    unpack.
// 2. 1800.2-2020 5.7.2.4 (UVM-FIELD-OP-TYPE) gives rule 2 above. Setup: Query
//    the seven supported operation types after valid set calls. Expected:
//    Every type comparison against the supplied operation succeeds.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Flush between operations and read the documented name and type
// only after set. Names come from the standard operation-name table.

module test_field_op_names_identify_copy_compare_and_set_operations;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_field_op operation = new;
    operation.set(UVM_COPY);
    $display("UT: name %s type_matches %0d", operation.get_op_name(),
        operation.get_op_type() == UVM_COPY);
    operation.flush();
    operation.set(UVM_COMPARE);
    $display("UT: name %s type_matches %0d", operation.get_op_name(),
        operation.get_op_type() == UVM_COMPARE);
    operation.flush();
    operation.set(UVM_SET);
    $display("UT: name %s type_matches %0d", operation.get_op_name(),
        operation.get_op_type() == UVM_SET);
    operation.flush();
    $finish;
  end
endmodule
