/*
:name: test_report_server_overridable_limit_and_count_reset
:description: an overridable quit maximum accepts updates independently of the count (IEEE 1800.2-2020 Section 6.5.1.2.2)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.2 6.5.1.2.3 6.5.1.2.4 6.5.1.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_overridable_limit_and_count_reset.expected
*/
// What it checks:
// 1. An overridable quit limit accepts later maximum values independently of
//    current quit count.
// 2. The current quit-count setter updates that count independently of its
//    maximum.
// 3. The maximum-quit getter returns the currently configured count.
// 4. The quit-count getter returns the current explicitly set count
//    independently of the limit.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.5.1.2.3 (UVM-REPORT-QUIT-LIMIT-UPDATE) gives rule 1 above.
//    Setup: Change the maximum to 8 and then 0 while current count is 6.
//    Expected: Queried maximum follows the updates without resetting current
//    count.
// 2. 1800.2-2020 6.5.1.2.5 (UVM-REPORT-QUIT-COUNT-UPDATE) gives rule 2 above.
//    Setup: Set/change/reset current counts with overridable or locked maximum
//    settings. Expected: Current count follows its assigned values while the
//    maximum retains its own setting.
// 3. 1800.2-2020 6.5.1.2.2 (UVM-REPORT-AUDIT-MAX-QUIT-GET) gives rule 3 above.
//    Setup: Use the selected original reporting fixtures and explicit object,
//    severity, ID and action configuration described by their observation
//    anchors. Expected: Queries reflect maximum updates, independent
//    current-count updates and reset to zero.
// 4. 1800.2-2020 6.5.1.2.4 (UVM-REPORT-AUDIT-QUIT-COUNT-GET) gives rule 4
//    above. Setup: Use the selected original reporting fixtures and explicit
//    object, severity, ID and action configuration described by their
//    observation anchors. Expected: Queries reflect maximum updates,
//    independent current-count updates and reset to zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An overridable limit can be changed and then set to zero. Changing the
// maximum and resetting the count are separate operations.

module test_report_server_overridable_limit_and_count_reset;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_default_report_server server = new;
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
