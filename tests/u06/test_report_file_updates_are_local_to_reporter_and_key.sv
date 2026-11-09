/*
:name: test_report_file_updates_are_local_to_reporter_and_key
:description: updating a report file leaves other keys and reporters unchanged (IEEE 1800.2-2020 Section 6.3.6.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.6.1 6.3.6.2 6.4.5.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_file_updates_are_local_to_reporter_and_key.expected
*/
// What it checks:
// File resolution prefers severity/ID, ID, severity, then the default
// destination.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.4.5.1 (UVM-REPORT-FILE-PRIORITY) gives the rule above. Setup:
// Open distinct files, configure keys and update one ID without changing
// another reporter. Expected: Descriptor identities follow specificity while
// unrelated keys/reporters retain their destinations.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Update one ID-specific file after a default file is configured.
// A separate reporter and an unmatched ID retain their own default files.

module test_report_file_updates_are_local_to_reporter_and_key;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object first = new("first");
    automatic uvm_report_object second = new("second");
    int handles[3];
    foreach (handles[i]) begin
      handles[i] = $fopen($sformatf("report-%0d.txt", i), "w");
      if (!handles[i]) $fatal(1, "cannot open report file");
    end
    first.set_report_default_file(handles[0]);
    second.set_report_default_file(handles[1]);
    first.set_report_id_file("M1_FILE", handles[1]);
    first.set_report_id_file("M1_FILE", handles[2]);
    $display("UT: changed %0d other_id %0d other_reporter %0d",
             first.get_report_file_handle(UVM_INFO, "M1_FILE") == handles[2],
             first.get_report_file_handle(UVM_INFO, "OTHER") == handles[0],
             second.get_report_file_handle(UVM_INFO, "M1_FILE") == handles[1]);
    foreach (handles[i]) $fclose(handles[i]);
    $finish;
  end
endmodule
