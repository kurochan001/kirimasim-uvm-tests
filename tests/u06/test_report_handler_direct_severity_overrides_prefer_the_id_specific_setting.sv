/*
:name: test_report_handler_direct_severity_overrides_prefer_the_id_specific_setting
:description: a severity override set directly on a report handler changes a report's severity, and an override for an id takes precedence over one for the severity alone (IEEE 1800.2-2020 Section 6.4.6)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.4.6 6.4.4.2 6.3.8.1 6.3.3.3 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_handler_direct_severity_overrides_prefer_the_id_specific_setting.expected
*/
// What it checks:
// A severity override set on the handler changes the severity of a report, and
// an override for a severity and id takes precedence over one for the severity
// alone.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.4.6 (UVM-HANDLER-DIRECT-SEVERITY-OVERRIDE) gives the rule
// above. Setup: take the handler of a report object with get_report_handler
// (6.3.8.1), make it display the three severities used (6.4.4.2), override
// UVM_WARNING by UVM_INFO, and for id H_PAIR override UVM_WARNING by
// UVM_WARNING. Issue a warning with H_PAIR, a warning with H_OTHER and an info
// with H_PAIR, and read the report server's counts (6.5.1.2.6) before and
// after. Expected: the H_PAIR warning stays a warning, the H_OTHER warning
// becomes an info, and the info is not affected, so the counts grow by two
// infos, one warning and no error.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The handler is configured directly; uvm_report_object's
// set_report_severity_override methods are not called.
module test_report_handler_direct_severity_overrides_prefer_the_id_specific_setting;
  import uvm_pkg::*;

  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic uvm_report_handler handler = reporter.get_report_handler();
    automatic uvm_report_server server = uvm_report_server::get_server();
    automatic int infos = server.get_severity_count(UVM_INFO);
    automatic int warnings = server.get_severity_count(UVM_WARNING);
    automatic int errors = server.get_severity_count(UVM_ERROR);
    handler.set_severity_action(UVM_INFO, UVM_DISPLAY);
    handler.set_severity_action(UVM_WARNING, UVM_DISPLAY);
    handler.set_severity_action(UVM_ERROR, UVM_DISPLAY);
    handler.set_severity_override(UVM_WARNING, UVM_INFO);
    handler.set_severity_id_override(UVM_WARNING, "H_PAIR", UVM_WARNING);
    reporter.uvm_report_warning("H_PAIR", "id override", UVM_NONE);
    reporter.uvm_report_warning("H_OTHER", "severity override", UVM_NONE);
    reporter.uvm_report_info("H_PAIR", "no override", UVM_NONE);
    $display("UT: deltas info %0d warning %0d error %0d",
             server.get_severity_count(UVM_INFO) - infos,
             server.get_severity_count(UVM_WARNING) - warnings,
             server.get_severity_count(UVM_ERROR) - errors);
    $finish;
  end
endmodule
