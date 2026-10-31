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
