/*
:name: test_report_handler_reset_restores_shared_id_settings
:description: resetting a shared handler restores its original ID-specific configuration (IEEE 1800.2-2020 Section 6.3.8.3)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.8.3 6.3.8.2 6.3.4.3 6.3.5.2 6.3.6.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_handler_reset_restores_shared_id_settings.expected
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
// Capture initial settings before configuring one ID. Reset through one
// report object and inspect the same handler through another report object.

module test_report_handler_reset_restores_shared_id_settings;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object first = new("first");
    automatic uvm_report_object second = new("second");
    automatic uvm_report_handler shared = new("shared");
    automatic int fd = $fopen("report-reset.txt", "w");
    uvm_action baseline_action;
    int baseline_verbosity;
    UVM_FILE baseline_file;
    if (!fd) $fatal(1, "cannot open report file");
    first.set_report_handler(shared);
    second.set_report_handler(shared);
    baseline_action = second.get_report_action(UVM_INFO, "M1_RESET");
    baseline_verbosity = second.get_report_verbosity_level(UVM_INFO, "M1_RESET");
    baseline_file = second.get_report_file_handle(UVM_INFO, "M1_RESET");
    first.set_report_id_action("M1_RESET", UVM_NO_ACTION);
    first.set_report_id_verbosity("M1_RESET", UVM_LOW);
    first.set_report_id_file("M1_RESET", fd);
    $display("UT: configured action %0d verbosity %0d file %0d",
             second.get_report_action(UVM_INFO, "M1_RESET") == UVM_NO_ACTION,
             second.get_report_verbosity_level(UVM_INFO, "M1_RESET") == UVM_LOW,
             second.get_report_file_handle(UVM_INFO, "M1_RESET") == fd);
    first.reset_report_handler();
    $display("UT: restored action %0d verbosity %0d file %0d",
             second.get_report_action(UVM_INFO, "M1_RESET") == baseline_action,
             second.get_report_verbosity_level(UVM_INFO, "M1_RESET") == baseline_verbosity,
             second.get_report_file_handle(UVM_INFO, "M1_RESET") == baseline_file);
    $fclose(fd);
    $finish;
  end
endmodule
