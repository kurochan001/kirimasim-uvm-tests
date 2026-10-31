/*
:name: test_report_server_overridable_limit_and_count_reset
:description: an overridable quit maximum accepts updates independently of the count (IEEE 1800.2-2020 Section 6.5.1.2.2)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.2 6.5.1.2.3 6.5.1.2.4 6.5.1.2.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_overridable_limit_and_count_reset.expected
*/
// An overridable limit can be changed and then set to zero. Changing the
// maximum and resetting the count are separate operations.

module test_report_server_overridable_limit_and_count_reset;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    uvm_default_report_server server = new;
    server.set_max_quit_count(3);
    server.set_max_quit_count(8);
    server.set_quit_count(6);
    $display("UT: changed maximum %0d current %0d", server.get_max_quit_count(),
             server.get_quit_count());
    server.set_max_quit_count(0);
    $display("UT: disabled maximum %0d current %0d", server.get_max_quit_count(),
             server.get_quit_count());
    server.set_quit_count(0);
    $display("UT: reset current %0d", server.get_quit_count());
    $finish;
  end
endmodule
