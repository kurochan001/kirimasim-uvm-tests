/*
:name: test_report_server_counts_severity_and_id
:description: processed reports increment severity and identifier counts (IEEE 1800.2-2020 Section 6.5.1.2.6)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.6 6.5.1.2.8 6.5.1.2.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_counts_severity_and_id.expected
*/
// Use differences from a baseline so initialization reports do not affect
// the observation. Count values are checked, not formatted report text.

module test_report_server_counts_severity_and_id;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

initial begin
  uvm_report_object reporter = new("reporter");
  uvm_report_server server = uvm_report_server::get_server();
  int infos = server.get_severity_count(UVM_INFO);
  int warnings = server.get_severity_count(UVM_WARNING);
  int ids = server.get_id_count("M1_COUNT");
  reporter.uvm_report_info("M1_COUNT", "first", UVM_NONE);
  reporter.uvm_report_info("M1_COUNT", "second", UVM_NONE);
  reporter.uvm_report_warning("M1_COUNT", "third", UVM_NONE);
  $display("UT: info %0d warning %0d id %0d", server.get_severity_count(UVM_INFO) - infos,
             server.get_severity_count(UVM_WARNING) - warnings,
             server.get_id_count("M1_COUNT") - ids);
  $finish;
end
endmodule
