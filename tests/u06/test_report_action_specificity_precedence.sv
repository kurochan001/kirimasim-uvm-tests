/*
:name: test_report_action_specificity_precedence
:description: severity-ID actions precede ID actions which precede severity actions (IEEE 1800.2-2020 Section 6.3.5.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.5.1 6.3.5.2 6.4.4.1 6.4.4.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_action_specificity_precedence.expected
*/
// Observe action values through getters. Distinct configurations expose
// each priority level without depending on report formatting or file I/O.

module test_report_action_specificity_precedence;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    uvm_report_object reporter = new("reporter");
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
