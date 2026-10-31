/*
:name: test_report_general_verbosity_keeps_specific_overrides
:description: updating general verbosity preserves more specific thresholds (IEEE 1800.2-2020 Section 6.3.4.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.4.1 6.3.4.4 6.3.3.2 6.4.3.1 6.4.3.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_general_verbosity_keeps_specific_overrides.expected
*/
// Changing the general threshold does not replace ID and severity-ID
// settings. A NONE threshold accepts NONE and rejects a higher verbosity.

module test_report_general_verbosity_keeps_specific_overrides;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    uvm_report_object reporter = new("reporter");
    reporter.set_report_verbosity_level(UVM_HIGH);
    reporter.set_report_id_verbosity("selected", UVM_LOW);
    reporter.set_report_severity_id_verbosity(UVM_INFO, "selected", UVM_NONE);
    reporter.set_report_verbosity_level(UVM_DEBUG);
    $display("UT: preserved pair %0d id %0d updated general %0d",
             reporter.get_report_verbosity_level(UVM_INFO, "selected") == UVM_NONE,
             reporter.get_report_verbosity_level(UVM_WARNING, "selected") == UVM_LOW,
             reporter.get_report_verbosity_level(UVM_INFO, "other") == UVM_DEBUG);
    $display("UT: boundary enabled %0d higher %0d", reporter.uvm_report_enabled(UVM_NONE,
             UVM_INFO, "selected"), reporter.uvm_report_enabled(UVM_LOW, UVM_INFO, "selected"));
    $finish;
  end
endmodule
