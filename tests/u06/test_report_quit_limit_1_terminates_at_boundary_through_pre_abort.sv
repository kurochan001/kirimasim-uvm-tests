/*
:name: test_report_quit_limit_1_terminates_at_boundary_through_pre_abort
:description: finite UVM_COUNT limit invokes real root termination at the configured boundary (IEEE 1800.2-2020 Section 6.5.1.2.3)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.3 6.5.1.2.4 6.5.1.2.5 F.2.2.2 F.7.3.2 13.1.4.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_quit_limit_1_terminates_at_boundary_through_pre_abort.expected
*/
// What it checks:
// The server invokes root termination when processed quit actions reach the
// configured finite limit.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.5.1.2.3 (UVM-REPORT-QUIT-LIMIT-TERMINATION) gives the rule
// above. Setup: Process UVM_COUNT reports at finite limits one/two, observing
// real pre_abort traversal and no later-time continuation. Expected: The
// configured boundary triggers termination rather than only changing a stored
// counter.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe the real pre_abort traversal, not a replacement root or counter
// getter alone. The guard checks that a later time step is not reached.
module test_report_quit_limit_1_terminates_at_boundary_through_pre_abort;
  import uvm_pkg::*;
  class abort_probe extends uvm_component;
    int expected_limit = 1;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    virtual function void pre_abort();
      uvm_report_server server;
      server = uvm_report_server::get_server();
      $display("UT: pre_abort boundary %0d", server.get_quit_count() == expected_limit);
    endfunction
  endclass
  initial begin
    abort_probe probe;
    uvm_report_object reporter;
    uvm_report_server server;
    probe = new("probe", null);
    reporter = new("reporter");
    server = uvm_report_server::get_server();
    reporter.set_report_severity_action(UVM_INFO, UVM_COUNT);
    server.set_max_quit_count(1);
    server.set_quit_count(0);
    $display("UT: initial_count %0d", server.get_quit_count());
    reporter.uvm_report_info("COUNT", "boundary", UVM_NONE);
    #1;
    $display("UT: unexpected_time_advance_after_boundary");
    $finish;
  end
  initial begin #50; $fatal(1, "quit-limit watchdog expired"); end
endmodule
