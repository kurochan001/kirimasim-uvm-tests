/*
:name: test_report_server_counts_belong_to_each_server
:description: separate report servers retain independent severity counters (IEEE 1800.2-2020 Section 6.5.1.2.6)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.6 6.5.1.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_counts_belong_to_each_server.expected
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
// Setting an ERROR or FATAL count is a state update, not a report. Reset
// one server counter and verify the other server and severity are intact.

module test_report_server_counts_belong_to_each_server;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_default_report_server first = new;
    automatic uvm_default_report_server second = new;
    first.set_severity_count(UVM_ERROR, 3);
    first.set_severity_count(UVM_FATAL, 1);
    second.set_severity_count(UVM_ERROR, 8);
    second.set_severity_count(UVM_FATAL, 0);
    first.set_severity_count(UVM_ERROR, 0);
    $display("UT: first error %0d fatal %0d", first.get_severity_count(UVM_ERROR),
             first.get_severity_count(UVM_FATAL));
    $display("UT: second error %0d fatal %0d", second.get_severity_count(UVM_ERROR),
             second.get_severity_count(UVM_FATAL));
    $finish;
  end
endmodule
