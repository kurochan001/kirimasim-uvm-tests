/*
:name: test_barrier_without_auto_reset_remains_open_until_explicit_reset
:description: disabled barrier auto-reset preserves an open gate until an explicit reset (IEEE 1800.2-2020 Section 10.3.2.4)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.3.2.4 10.3.2.1 10.3.2.2 10.3.2.3 10.3.2.5 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_barrier_without_auto_reset_remains_open_until_explicit_reset.expected
*/
// What it checks:
// With auto-reset disabled a reached barrier remains open until an explicit
// reset.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.3.2.4 (UVM-BARRIER-DISABLED-AUTO-RESET) gives the rule above.
// Setup: Reach a threshold of two, call through the open gate, reset and
// repeat. Expected: The open call returns at the same time; reset makes the
// next call wait for a second participant again.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive delays establish waiting states. The fixtures do not require a
// particular order among processes released at the same synchronization point.
module test_barrier_without_auto_reset_remains_open_until_explicit_reset;
  import uvm_pkg::*;
  typedef bit [31:0] word_t;
  uvm_barrier barrier_value;
  bit first_done = 0;
  bit fresh_done = 0;
  time before_wait;
  initial begin

    barrier_value = new("barrier_value", 2); barrier_value.set_auto_reset(0);
    fork
      begin barrier_value.wait_for(); first_done = 1; end
      begin
        #1; $display("UT: initial blocked %0d waiters %0d", !first_done,
                    barrier_value.get_num_waiters());
        barrier_value.wait_for();
      end
    join
    before_wait = $time; barrier_value.wait_for();
    $display("UT: open immediate %0d waiters %0d", $time == before_wait,
             barrier_value.get_num_waiters());
    barrier_value.reset();
    fork
      begin barrier_value.wait_for(); fresh_done = 1; end
      begin
        #1; $display("UT: after_reset blocked %0d waiters %0d threshold %0d", !fresh_done,
                    barrier_value.get_num_waiters(), barrier_value.get_threshold());
        barrier_value.wait_for();
      end
    join
    $display("UT: rearmed_done %0d waiters %0d", fresh_done, barrier_value.get_num_waiters());

    $finish;
  end
  initial begin #60; $fatal(1, "synchronization watchdog expired"); end
endmodule
