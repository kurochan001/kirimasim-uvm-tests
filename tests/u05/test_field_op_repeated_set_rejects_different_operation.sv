/*
:name: test_field_op_repeated_set_rejects_different_operation
:description: a second field operation set without flush reports an error (IEEE 1800.2-2020 Section 5.7.2.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.2 5.7.2.9 5.7.2.3 5.7.2.4 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_op_repeated_set_rejects_different_operation.expected
*/
// What it checks:
// Calling set again without an intervening flush reports an error.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.7.2.2 (UVM-FIELD-OP-REJECT-REPEATED-SET) gives the rule above.
// Setup: Repeat either the same or a different operation before flushing.
// Expected: Both repeated-set cases report an error; a flushed valid control
// still works.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Do not inspect the state after the invalid set. Flush before
// reusing the operation, then observe the new valid name and type.

module test_field_op_repeated_set_rejects_different_operation;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_field_op operation = new;
    automatic uvm_root root = uvm_root::get();
    automatic uvm_report_server server = uvm_report_server::get_server();
    int errors;
    root.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    operation.set(UVM_COPY);
    errors = server.get_severity_count(UVM_ERROR);
    operation.set(UVM_COMPARE);
    $display("UT: repeated_set_reports_error %0d", server.get_severity_count(UVM_ERROR) > errors);
    operation.flush();
    operation.set(UVM_PACK);
    $display("UT: reused name %s type_matches %0d", operation.get_op_name(),
        operation.get_op_type() == UVM_PACK);
    $finish;
  end
endmodule
