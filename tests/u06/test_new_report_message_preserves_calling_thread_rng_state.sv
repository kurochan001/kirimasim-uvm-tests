/*
:name: test_new_report_message_preserves_calling_thread_rng_state
:description: the report message creation helper preserves its calling thread RNG state (IEEE 1800.2-2020 Section 6.2.2.2)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.2.2.2 6.2.2.1 5.3.4.1 1800-2023 6.21 9.7 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_new_report_message_preserves_calling_thread_rng_state.expected
*/
// What it checks:
// new_report_message preserves the RNG state of its calling thread.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.2.2.2 (UVM-REPORT-MESSAGE-THREAD-RNG) gives the rule above.
// Setup: Call twice from an initial process and compare opaque RNG state
// before/after. Expected: Both calls preserve state and create distinct named
// messages.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Call from an initial process, not a non-thread context. Compare the
// opaque process RNG state for equality without prescribing its encoding.

module test_new_report_message_preserves_calling_thread_rng_state;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic process caller = process::self();
    uvm_report_message first;
    uvm_report_message second;
    string before_state;
    if (caller == null) $fatal(1, "calling process not found");
    caller.srandom(53);
    before_state = caller.get_randstate();
    first = uvm_report_message::new_report_message("first");
    $display("UT: first_state_unchanged %0d", caller.get_randstate() == before_state);
    before_state = caller.get_randstate();
    second = uvm_report_message::new_report_message("second");
    $display("UT: second_state_unchanged %0d", caller.get_randstate() == before_state);
    if (first == null || second == null) $fatal(1, "message not created");
    $display("UT: distinct %0d names %s %s", first != second, first.get_name(), second.get_name());
    $finish;
  end
endmodule
