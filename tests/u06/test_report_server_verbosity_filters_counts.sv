/*
:name: test_report_server_verbosity_filters_counts
:description: verbosity-filtered messages do not reach the report server counts (IEEE 1800.2-2020 Section 6.5.1.2.6)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.6 6.5.1.2.8 6.5.1.2.16 6.3.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_verbosity_filters_counts.expected
*/
// What it checks:
// 1. The server reports processed-message counts per severity.
// 2. The server reports processed-message counts for the requested ID.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.5.1.2.6 (UVM-REPORT-SERVER-SEVERITY-COUNT) gives rule 1
//    above. Setup: Compare baseline-relative counts for accepted reports and a
//    verbosity-filtered report. Expected: Accepted messages increment their
//    severity count; a filtered message adds none.
// 2. 1800.2-2020 6.5.1.2.8 (UVM-REPORT-SERVER-ID-COUNT) gives rule 2 above.
//    Setup: Issue messages with one controlled ID, including a filtered call.
//    Expected: The ID count reflects accepted reports only.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An info message above the configured verbosity is filtered before the
// server. An enabled info message increments both severity and ID counts.

module test_report_server_verbosity_filters_counts;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

initial begin
  automatic uvm_report_object reporter = new("reporter");
  automatic uvm_report_server server = uvm_report_server::get_server();
  automatic int infos = server.get_severity_count(UVM_INFO);
  automatic int ids = server.get_id_count("M1_FILTER");
  reporter.set_report_verbosity_level(UVM_LOW);
  reporter.uvm_report_info("M1_FILTER", "filtered", UVM_HIGH);
  $display("UT: filtered info %0d id %0d", server.get_severity_count(UVM_INFO) - infos,
           server.get_id_count("M1_FILTER") - ids);
  reporter.uvm_report_info("M1_FILTER", "enabled", UVM_LOW);
  $display("UT: enabled info %0d id %0d", server.get_severity_count(UVM_INFO) - infos,
           server.get_id_count("M1_FILTER") - ids);
  $finish;
end
endmodule
