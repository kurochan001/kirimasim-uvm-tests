/*
:name: test_reporting_verbosity_filters_info_but_not_warning_error_or_fatal
:description: non-info severities ignore the supplied verbosity threshold (IEEE 1800.2-2020 Section 6.3.3.3)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.3.3 6.3.4.3 6.3.5.2 6.6.3.2 6.6 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reporting_verbosity_filters_info_but_not_warning_error_or_fatal.expected
*/
// All reports are caught before emission. Only callback admission is checked;
// no demotion, severity override, formatted diagnostic or fatal exit is tested.
module test_reporting_verbosity_filters_info_but_not_warning_error_or_fatal;
  import uvm_pkg::*;
  class probe_type extends uvm_report_catcher;
    int infos = 0, warnings = 0, errors = 0, fatals = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      case (get_severity())
        UVM_INFO: infos++;
        UVM_WARNING: warnings++;
        UVM_ERROR: errors++;
        UVM_FATAL: fatals++;
      endcase
      return CAUGHT;
    endfunction
  endclass
  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic probe_type probe = new();
    reporter.set_report_verbosity_level(UVM_NONE);
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_WARNING, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_FATAL, UVM_DISPLAY);
    uvm_report_cb::add(reporter, probe);
    reporter.uvm_report_info("hidden", "payload", UVM_LOW);
    $display("UT: filtered info %0d", probe.infos);
    reporter.uvm_report_info("visible", "payload", UVM_NONE);
    reporter.uvm_report_warning("warning", "payload", UVM_DEBUG);
    reporter.uvm_report_error("error", "payload", UVM_DEBUG);
    reporter.uvm_report_fatal("fatal", "payload", UVM_DEBUG);
    $display("UT: callbacks info %0d warning %0d error %0d fatal %0d", probe.infos,
             probe.warnings, probe.errors, probe.fatals);
    uvm_report_cb::delete(reporter, probe); $finish;
  end
endmodule
