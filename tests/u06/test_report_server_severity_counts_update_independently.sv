/*
:name: test_report_server_severity_counts_update_independently
:description: setting a severity count updates only that severity (IEEE 1800.2-2020 Section 6.5.1.2.6)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.6 6.5.1.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_severity_counts_update_independently.expected
*/
// What it checks:
// A manual severity-count update affects only the selected server and
// severity.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.5.1.2.7 (UVM-REPORT-SERVER-SET-SEVERITY-COUNT) gives the rule
// above. Setup: Use independent servers and different severity counters
// without processing reports. Expected: The selected counter changes while
// other severities and the other server retain their values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use a separate default report server so framework reports do not enter
// the observations. Changing INFO does not change WARNING.

module test_report_server_severity_counts_update_independently;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_default_report_server server = new;
    server.set_severity_count(UVM_INFO, 4);
    server.set_severity_count(UVM_WARNING, 2);
    $display("UT: initial info %0d warning %0d", server.get_severity_count(UVM_INFO),
             server.get_severity_count(UVM_WARNING));
    server.set_severity_count(UVM_INFO, 7);
    $display("UT: updated info %0d warning %0d", server.get_severity_count(UVM_INFO),
             server.get_severity_count(UVM_WARNING));
    $finish;
  end
endmodule
