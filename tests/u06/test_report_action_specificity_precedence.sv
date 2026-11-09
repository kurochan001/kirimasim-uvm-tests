/*
:name: test_report_action_specificity_precedence
:description: severity-ID actions precede ID actions which precede severity actions (IEEE 1800.2-2020 Section 6.3.5.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.5.1 6.3.5.2 6.4.4.1 6.4.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_action_specificity_precedence.expected
*/
// What it checks:
// 1. Action resolution prefers severity/ID over ID over severity.
// 2. Configured severity, ID and severity-ID actions are retrievable with
//    their defined priority.
// 3. The public action getter returns the handler-resolved severity/ID action.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.4.4.1 (UVM-REPORT-ACTION-PRIORITY) gives rule 1 above.
//    Setup: Configure different action values at all three levels and query
//    matching/fallback keys. Expected: Each query returns its most specific
//    configured action.
// 2. 1800.2-2020 6.4.4.2 (UVM-HANDLER-CONFIG-ACTION-ASSOCIATIONS) gives rule 2
//    above. Setup: Distinct actions are installed at all three specificity
//    levels. Expected: Pair, ID and severity fallback queries retrieve the
//    respective configured actions.
// 3. 1800.2-2020 6.3.5.1 (UVM-REPORT-AUDIT-ACTION-QUERY-DELEGATION) gives rule
//    3 above. Setup: Use the selected original reporting fixtures and explicit
//    object, severity, ID and action configuration described by their
//    observation anchors. Expected: Pair overrides ID and ID overrides
//    severity; the untouched severity action remains the fallback.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe action values through getters. Distinct configurations expose
// each priority level without depending on report formatting or file I/O.

module test_report_action_specificity_precedence;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object reporter = new("reporter");
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    reporter.set_report_id_action("selected", UVM_NO_ACTION);
    reporter.set_report_severity_id_action(UVM_INFO, "selected", UVM_DISPLAY | UVM_LOG);
    $display("UT: pair wins %0d", reporter.get_report_action(UVM_INFO, "selected") ==
             (UVM_DISPLAY | UVM_LOG));
    $display("UT: id wins %0d", reporter.get_report_action(UVM_WARNING, "selected") ==
             UVM_NO_ACTION);
    $display("UT: severity fallback %0d", reporter.get_report_action(UVM_INFO, "other") ==
             UVM_DISPLAY);
    $finish;
  end
endmodule
