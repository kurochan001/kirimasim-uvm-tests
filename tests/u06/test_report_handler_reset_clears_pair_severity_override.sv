/*
:name: test_report_handler_reset_clears_pair_severity_override
:description: resetting a report handler clears a severity and ID override (IEEE 1800.2-2020 Section 6.3.8.3)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.8.3 6.3.7 6.4.6 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_handler_reset_clears_pair_severity_override.expected
*/
// What it checks:
// Resetting a report handler restores default settings and clears severity
// overrides.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.3.8.3 (UVM-REPORT-HANDLER-RESET) gives the rule above. Setup:
// Configure shared ID action/verbosity/file settings and a severity/ID
// override, then reset. Expected: Saved defaults return and the previously
// overridden report uses its original severity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned library retains severity-ID overrides across initialize.
// Keep the required reset behavior as a spec-only case with count deltas.

module test_report_handler_reset_clears_pair_severity_override;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic uvm_report_server server = uvm_report_server::get_server();
    automatic int errors = server.get_severity_count(UVM_ERROR);
    automatic int warnings = server.get_severity_count(UVM_WARNING);
    reporter.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_WARNING, UVM_DISPLAY);
    reporter.set_report_severity_id_override(UVM_ERROR, "M1_RESET_PAIR", UVM_WARNING);
    reporter.uvm_report_error("M1_RESET_PAIR", "before reset", UVM_NONE);
    $display("UT: before error %0d warning %0d", server.get_severity_count(UVM_ERROR) - errors,
             server.get_severity_count(UVM_WARNING) - warnings);
    reporter.reset_report_handler();
    reporter.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_WARNING, UVM_DISPLAY);
    errors = server.get_severity_count(UVM_ERROR);
    warnings = server.get_severity_count(UVM_WARNING);
    reporter.uvm_report_error("M1_RESET_PAIR", "after reset", UVM_NONE);
    $display("UT: after error %0d warning %0d", server.get_severity_count(UVM_ERROR) - errors,
             server.get_severity_count(UVM_WARNING) - warnings);
    $finish;
  end
endmodule
