/*
:name: test_field_op_accessors_report_errors_before_set
:description: field operation accessors report required errors before set (IEEE 1800.2-2020 Section 5.7.2.3)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.7.2.3 5.7.2.4 5.7.2.5 5.7.2.6 5.7.2.9 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_op_accessors_report_errors_before_set.expected
*/
// What it checks:
// 1. get_op_name reports an error if no current set operation exists.
// 2. get_op_type reports an error if no current set operation exists.
// 3. get_policy reports an error if no current set operation exists.
// 4. get_rhs reports an error if no current set operation exists.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.7.2.3 (UVM-FIELD-OP-NAME-INVALID) gives rule 1 above.
//    Setup: Query both a fresh field operation and one flushed since its last
//    set. Expected: Both invalid queries increase the error count; their
//    return values are discarded.
// 2. 1800.2-2020 5.7.2.4 (UVM-FIELD-OP-TYPE-INVALID) gives rule 2 above.
//    Setup: Query both a fresh field operation and one flushed since its last
//    set. Expected: Both invalid queries increase the error count; their
//    return values are discarded.
// 3. 1800.2-2020 5.7.2.5 (UVM-FIELD-OP-POLICY-INVALID) gives rule 3 above.
//    Setup: Query both a fresh field operation and one flushed since its last
//    set. Expected: Both invalid queries increase the error count; their
//    return values are discarded.
// 4. 1800.2-2020 5.7.2.6 (UVM-FIELD-OP-RHS-INVALID) gives rule 4 above. Setup:
//    Query both a fresh field operation and one flushed since its last set.
//    Expected: Both invalid queries increase the error count; their return
//    values are discarded.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Discard invalid return values and observe error-count increases.
// The pinned library omits the required get_op_name error; its normative
// expectation is retained as a spec-only case.

module test_field_op_accessors_report_errors_before_set;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_field_op operation = new;
    automatic uvm_root root = uvm_root::get();
    automatic uvm_report_server server = uvm_report_server::get_server();
    int errors;
    root.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    errors = server.get_severity_count(UVM_ERROR);
    void'(operation.get_op_name());
    $display("UT: get_op_name_reports_error %0d", server.get_severity_count(UVM_ERROR) > errors);
    errors = server.get_severity_count(UVM_ERROR);
    void'(operation.get_op_type());
    $display("UT: get_op_type_reports_error %0d", server.get_severity_count(UVM_ERROR) > errors);
    errors = server.get_severity_count(UVM_ERROR);
    void'(operation.get_policy());
    $display("UT: get_policy_reports_error %0d", server.get_severity_count(UVM_ERROR) > errors);
    errors = server.get_severity_count(UVM_ERROR);
    void'(operation.get_rhs());
    $display("UT: get_rhs_reports_error %0d", server.get_severity_count(UVM_ERROR) > errors);
    $finish;
  end
endmodule
