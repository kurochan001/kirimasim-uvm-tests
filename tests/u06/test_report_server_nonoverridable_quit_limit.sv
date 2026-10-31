/*
:name: test_report_server_nonoverridable_quit_limit
:description: a quit limit made nonoverridable retains its first configured value (IEEE 1800.2-2020 Section 6.5.1.2.2)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.2 6.5.1.2.3 6.5.1.2.4 6.5.1.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_nonoverridable_quit_limit.expected
*/
// A nonoverridable maximum rejects later updates. The current quit count
// can still be set independently without processing an actual error report.

module test_report_server_nonoverridable_quit_limit;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_default_report_server server = new;
    server.set_max_quit_count(5, 0);
    server.set_max_quit_count(9, 1);
    server.set_quit_count(3);
    $display("UT: maximum %0d current %0d", server.get_max_quit_count(), server.get_quit_count());
    server.set_quit_count(1);
    $display("UT: retained maximum %0d changed current %0d", server.get_max_quit_count(),
             server.get_quit_count());
    $finish;
  end
endmodule
