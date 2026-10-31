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
