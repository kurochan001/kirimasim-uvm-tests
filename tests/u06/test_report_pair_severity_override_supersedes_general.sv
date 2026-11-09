/*
:name: test_report_pair_severity_override_supersedes_general
:description: a severity and ID override supersedes a general severity override (IEEE 1800.2-2020 Section 6.3.7)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.7 6.4.6 6.5.1.2.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_pair_severity_override_supersedes_general.expected
*/
// What it checks:
// 1. A severity-and-ID override takes priority over an override for severity
//    alone.
// 2. Public severity override wrappers affect selected reports and preserve
//    more specific ID selection.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.4.6 (UVM-REPORT-OVERRIDE-PRIORITY) gives rule 1 above.
//    Setup: A matching ID and a different ID are reported under overlapping
//    severity overrides. Expected: The resulting deltas are info 1, warning 1
//    and error 0.
// 2. 1800.2-2020 6.3.7 (UVM-REPORT-AUDIT-SEVERITY-OVERRIDE-WRAPPERS) gives
//    rule 2 above. Setup: Use the selected original reporting fixtures and
//    explicit object, severity, ID and action configuration described by their
//    observation anchors. Expected: An ID-scoped promotion leaves a peer
//    unchanged, replacement takes effect, and a pair override takes priority
//    over the general override.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Compare report-server count deltas after two ERROR requests. A pair
// override maps one to INFO and a general override maps the other to WARNING.

module test_report_pair_severity_override_supersedes_general;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic uvm_report_server server = uvm_report_server::get_server();
    automatic int infos = server.get_severity_count(UVM_INFO);
    automatic int warnings = server.get_severity_count(UVM_WARNING);
    automatic int errors = server.get_severity_count(UVM_ERROR);
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_WARNING, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    reporter.set_report_severity_override(UVM_ERROR, UVM_WARNING);
    reporter.set_report_severity_id_override(UVM_ERROR, "M1_PAIR", UVM_INFO);
    reporter.uvm_report_error("M1_PAIR", "pair override", UVM_NONE);
    reporter.uvm_report_error("M1_OTHER", "general override", UVM_NONE);
    $display("UT: deltas info %0d warning %0d error %0d",
             server.get_severity_count(UVM_INFO) - infos,
             server.get_severity_count(UVM_WARNING) - warnings,
             server.get_severity_count(UVM_ERROR) - errors);
    $finish;
  end
endmodule
