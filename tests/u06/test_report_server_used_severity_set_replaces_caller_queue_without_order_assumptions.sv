/*
:name: test_report_server_used_severity_set_replaces_caller_queue_without_order_assumptions
:description: report server used severity set replaces caller queue without order assumptions
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.10 6.5.1.2.6 6.3.3.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_used_severity_set_replaces_caller_queue_without_order_assumptions.expected
*/
// What it checks:
// The severity-set output lists each exercised standard severity without
// retaining caller queue contents.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.5.1.2.10 (UVM-REPORT-AUDIT-USED-SEVERITY-SET-OUTPUT) gives the
// rule above. Setup: Use the selected original reporting fixtures and explicit
// object, severity, ID and action configuration described by their observation
// anchors. Expected: After all four severities and one repeated info report,
// each appears once with no stale value; requery returns four after the caller
// deletes its copy.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_report_server_used_severity_set_replaces_caller_queue_without_order_assumptions;
  import uvm_pkg::*;
  // Exercise every standard severity. Initial unused membership is not
  // inferred from implementations that preallocate zero-valued counters.
  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic uvm_report_server server = uvm_report_server::get_server();
    automatic uvm_severity values[$] = '{uvm_severity'(99)};
    automatic int info = 0, warning = 0, error_count = 0, fatal_count = 0, stale = 0;
    automatic int info_before = server.get_severity_count(UVM_INFO);
    automatic int warning_before = server.get_severity_count(UVM_WARNING);
    automatic int error_before = server.get_severity_count(UVM_ERROR);
    automatic int fatal_before = server.get_severity_count(UVM_FATAL);
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_WARNING, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_FATAL, UVM_DISPLAY);
    reporter.uvm_report_info("all_info", "one", UVM_NONE);
    reporter.uvm_report_warning("all_warning", "two");
    reporter.uvm_report_error("all_error", "three");
    reporter.uvm_report_fatal("all_fatal", "four");
    reporter.uvm_report_info("all_info", "repeat", UVM_NONE);
    server.get_severity_set(values);
    foreach (values[i]) begin
      case (values[i])
        UVM_INFO: info++;
        UVM_WARNING: warning++;
        UVM_ERROR: error_count++;
        UVM_FATAL: fatal_count++;
        default: stale++;
      endcase
    end
    $display("UT: severity_set size %0d members %0d/%0d/%0d/%0d stale %0d", values.size(),
             info, warning, error_count, fatal_count, stale);
    values.delete(); server.get_severity_set(values);
    $display("UT: severity_requery size %0d counts %0d/%0d/%0d/%0d", values.size(),
             server.get_severity_count(UVM_INFO) - info_before,
             server.get_severity_count(UVM_WARNING) - warning_before,
             server.get_severity_count(UVM_ERROR) - error_before,
             server.get_severity_count(UVM_FATAL) - fatal_before);
    $finish;
  end
endmodule
