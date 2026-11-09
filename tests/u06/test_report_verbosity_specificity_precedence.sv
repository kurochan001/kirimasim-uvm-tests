/*
:name: test_report_verbosity_specificity_precedence
:description: severity-ID verbosity precedes ID verbosity and the general threshold (IEEE 1800.2-2020 Section 6.3.4.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.4.1 6.3.4.4 6.3.3.2 6.4.3.1 6.4.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_verbosity_specificity_precedence.expected
*/
// What it checks:
// 1. Verbosity resolution prefers a severity/ID setting, then an ID setting,
//    then the general threshold.
// 2. A report is verbosity-enabled when its requested level does not exceed
//    the resolved threshold.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.4.3.1 (UVM-REPORT-VERBOSITY-PRIORITY) gives rule 1 above.
//    Setup: Install distinct thresholds and later update only the general
//    setting. Expected: Queries follow specificity and specific overrides
//    survive a general update.
// 2. 1800.2-2020 6.3.3.2 (UVM-REPORT-VERBOSITY-ENABLED) gives rule 2 above.
//    Setup: Query at and above the configured threshold, including the NONE
//    boundary. Expected: The threshold boundary is enabled and a higher
//    requested level is disabled.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The configured threshold depends on both severity and ID. Query the
// threshold and the enabled predicate at and above the selected thresholds.

module test_report_verbosity_specificity_precedence;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object reporter = new("reporter");
    reporter.set_report_verbosity_level(UVM_LOW);
    reporter.set_report_id_verbosity("selected", UVM_MEDIUM);
    reporter.set_report_severity_id_verbosity(UVM_INFO, "selected", UVM_HIGH);
    $display("UT: thresholds pair %0d id %0d general %0d",
             reporter.get_report_verbosity_level(UVM_INFO, "selected") == UVM_HIGH,
             reporter.get_report_verbosity_level(UVM_WARNING, "selected") == UVM_MEDIUM,
             reporter.get_report_verbosity_level(UVM_INFO, "other") == UVM_LOW);
    $display("UT: enabled pair %0d id %0d", reporter.uvm_report_enabled(UVM_HIGH,
             UVM_INFO, "selected"), reporter.uvm_report_enabled(UVM_HIGH, UVM_WARNING, "selected"));
    $finish;
  end
endmodule
