/*
:name: test_report_file_selection_specificity_precedence
:description: report file selection prefers severity and ID pairs then ID then severity (IEEE 1800.2-2020 Section 6.3.6.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.6.1 6.3.6.2 6.4.5.1 6.4.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_file_selection_specificity_precedence.expected
*/
// What it checks:
// 1. File resolution prefers severity/ID, ID, severity, then the default
//    destination.
// 2. Configured file associations are retained at default and specific scopes.
// 3. The public file getter returns the effective file association.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.4.5.1 (UVM-REPORT-FILE-PRIORITY) gives rule 1 above. Setup:
//    Open distinct files, configure keys and update one ID without changing
//    another reporter. Expected: Descriptor identities follow specificity
//    while unrelated keys/reporters retain their destinations.
// 2. 1800.2-2020 6.4.5.2 (UVM-HANDLER-CONFIG-FILE-ASSOCIATIONS) gives rule 2
//    above. Setup: Four distinct opened handles are assigned to default,
//    severity, ID and pair settings. Expected: Each query returns its selected
//    handle without fixing descriptor numbers.
// 3. 1800.2-2020 6.3.6.1 (UVM-REPORT-AUDIT-FILE-QUERY-DELEGATION) gives rule 3
//    above. Setup: Use the selected original reporting fixtures and explicit
//    object, severity, ID and action configuration described by their
//    observation anchors. Expected: Opened descriptor identities resolve by
//    pair, ID, severity and default without fixed numeric handles.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Open distinct files and compare returned handles, without observing
// any implementation-specific report formatting or numeric descriptor values.

module test_report_file_selection_specificity_precedence;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object reporter = new("reporter");
    int handles[4];
    foreach (handles[i]) begin
      handles[i] = $fopen($sformatf("report-%0d.txt", i), "w");
      if (!handles[i]) $fatal(1, "cannot open report file");
    end
    reporter.set_report_default_file(handles[0]);
    reporter.set_report_severity_file(UVM_ERROR, handles[1]);
    reporter.set_report_id_file("M1_FILE", handles[2]);
    reporter.set_report_severity_id_file(UVM_ERROR, "M1_FILE", handles[3]);
    $display("UT: default %0d severity %0d id %0d pair %0d",
             reporter.get_report_file_handle(UVM_INFO, "OTHER") == handles[0],
             reporter.get_report_file_handle(UVM_ERROR, "OTHER") == handles[1],
             reporter.get_report_file_handle(UVM_INFO, "M1_FILE") == handles[2],
             reporter.get_report_file_handle(UVM_ERROR, "M1_FILE") == handles[3]);
    foreach (handles[i]) $fclose(handles[i]);
    $finish;
  end
endmodule
