/*
:name: test_field_op_names_identify_display_and_stream_operations
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
:expected_stdout: @test_field_op_names_identify_display_and_stream_operations.expected
*/
// Flush between operations and read the documented name and type
// only after set. Names come from the standard operation-name table.

module test_field_op_names_identify_display_and_stream_operations;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_field_op operation = new;
    operation.set(UVM_PRINT);
    $display("UT: name %s type_matches %0d", operation.get_op_name(),
        operation.get_op_type() == UVM_PRINT);
    operation.flush();
    operation.set(UVM_RECORD);
    $display("UT: name %s type_matches %0d", operation.get_op_name(),
        operation.get_op_type() == UVM_RECORD);
    operation.flush();
    operation.set(UVM_PACK);
    $display("UT: name %s type_matches %0d", operation.get_op_name(),
        operation.get_op_type() == UVM_PACK);
    operation.flush();
    operation.set(UVM_UNPACK);
    $display("UT: name %s type_matches %0d", operation.get_op_name(),
        operation.get_op_type() == UVM_UNPACK);
    operation.flush();
    $finish;
  end
endmodule
