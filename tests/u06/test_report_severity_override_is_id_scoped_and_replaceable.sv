/*
:name: test_report_severity_override_is_id_scoped_and_replaceable
:description: an ID-specific severity override leaves other IDs unchanged and can be replaced (IEEE 1800.2-2020 Section 6.3.7)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.7 6.4.6 6.5.1.2.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_severity_override_is_id_scoped_and_replaceable.expected
*/
// Upgrade one INFO ID to WARNING, leave a second ID at INFO, then
// replace the override with INFO and observe the new report count deltas.

module test_report_severity_override_is_id_scoped_and_replaceable;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic uvm_report_server server = uvm_report_server::get_server();
    automatic int infos = server.get_severity_count(UVM_INFO);
    automatic int warnings = server.get_severity_count(UVM_WARNING);
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_WARNING, UVM_DISPLAY);
    reporter.set_report_severity_id_override(UVM_INFO, "M1_UPGRADE", UVM_WARNING);
    reporter.uvm_report_info("M1_UPGRADE", "upgraded", UVM_NONE);
    reporter.uvm_report_info("M1_OTHER", "unchanged", UVM_NONE);
    $display("UT: scoped info %0d warning %0d", server.get_severity_count(UVM_INFO) - infos,
             server.get_severity_count(UVM_WARNING) - warnings);
    reporter.set_report_severity_id_override(UVM_INFO, "M1_UPGRADE", UVM_INFO);
    reporter.uvm_report_info("M1_UPGRADE", "replaced", UVM_NONE);
    $display("UT: replaced info %0d warning %0d", server.get_severity_count(UVM_INFO) - infos,
             server.get_severity_count(UVM_WARNING) - warnings);
    $finish;
  end
endmodule
