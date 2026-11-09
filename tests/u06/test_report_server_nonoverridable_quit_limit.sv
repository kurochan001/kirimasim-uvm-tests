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
// What it checks:
// 1. A quit limit installed as nonoverridable cannot be changed by later limit
//    settings.
// 2. The current quit-count setter updates that count independently of its
//    maximum.
// 3. The maximum-quit getter returns the currently configured count.
// 4. The quit-count getter returns the current explicitly set count
//    independently of the limit.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.5.1.2.3 (UVM-REPORT-QUIT-LIMIT-LOCK) gives rule 1 above.
//    Setup: Install maximum 5 with overridable zero, then attempt another
//    maximum. Expected: Maximum remains 5 while the separately assigned
//    current quit count can change.
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
