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
