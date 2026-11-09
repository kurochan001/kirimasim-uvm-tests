/*
:name: test_report_no_action_suppresses_counts
:description: NO_ACTION reports leave severity and ID counts unchanged (IEEE 1800.2-2020 Section 6.3.5.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.5.1 6.3.5.2 6.5.1.2.14 6.5.1.2.6 6.5.1.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_no_action_suppresses_counts.expected
*/
// What it checks:
// Report processing ends without executing the report when its action is
// UVM_NO_ACTION.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.5.1.2.14 (UVM-REPORT-NO-ACTION) gives the rule above. Setup:
// An enabled info report is first suppressed by action, then restored to a
// counting action. Expected: Suppression adds no severity or ID counts; the
// enabled control adds one to each.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A message with NO_ACTION stops before execution by the report server.
// Changing the ID action to DISPLAY enables subsequent messages.

module test_report_no_action_suppresses_counts;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic uvm_report_server server = uvm_report_server::get_server();
    automatic int infos = server.get_severity_count(UVM_INFO);
    automatic int ids = server.get_id_count("M1_ACTION");
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    reporter.set_report_id_action("M1_ACTION", UVM_NO_ACTION);
    reporter.uvm_report_info("M1_ACTION", "suppressed", UVM_NONE);
    $display("UT: suppressed info %0d id %0d action %0d",
             server.get_severity_count(UVM_INFO) - infos, server.get_id_count("M1_ACTION") - ids,
             reporter.get_report_action(UVM_INFO, "M1_ACTION") == UVM_NO_ACTION);
    reporter.set_report_id_action("M1_ACTION", UVM_DISPLAY);
    reporter.uvm_report_info("M1_ACTION", "enabled", UVM_NONE);
    $display("UT: enabled info %0d id %0d action %0d",
             server.get_severity_count(UVM_INFO) - infos, server.get_id_count("M1_ACTION") - ids,
             reporter.get_report_action(UVM_INFO, "M1_ACTION") == UVM_DISPLAY);
    $finish;
  end
endmodule
