/*
:name: test_barrier_default_reset_wakes_pending_waiters_and_rearms_the_same_threshold
:description: barrier reset wakes pending processes and requires the unchanged threshold on reuse (IEEE 1800.2-2020 Section 10.3.2.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.3.2.3 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_barrier_default_reset_wakes_pending_waiters_and_rearms_the_same_threshold.expected
*/
// What it checks:
// Default barrier reset wakes pending callers, clears the count and rearms
// with the unchanged threshold.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.3.2.3 (UVM-BARRIER-RESET-WAKE-REARM) gives the rule above.
// Setup: Reset two pending callers below threshold three, then run a fresh
// three-participant round. Expected: Reset releases both and retains threshold
// three; the fresh round blocks until its third caller.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive delays establish waiting states. The fixtures do not require a
// particular order among processes released at the same synchronization point.
module test_barrier_default_reset_wakes_pending_waiters_and_rearms_the_same_threshold;
  import uvm_pkg::*;
  typedef bit [31:0] word_t;
  uvm_barrier barrier_value;
  bit [2:0] completed = 0;
  initial begin

    barrier_value = new("barrier_value", 3);
    fork
      begin barrier_value.wait_for(); completed[0] = 1; end
      begin barrier_value.wait_for(); completed[1] = 1; end
      begin
        #1;
        $display("UT: before_reset blocked %0d waiters %0d", completed == 0,
                 barrier_value.get_num_waiters());
        barrier_value.reset();
      end
    join
    $display("UT: reset released %0d waiters %0d threshold %0d", completed == 3,
             barrier_value.get_num_waiters(), barrier_value.get_threshold());
    #1; completed = 0;
    fork
      begin barrier_value.wait_for(); completed[0] = 1; end
      begin barrier_value.wait_for(); completed[1] = 1; end
      begin
        #1;
        $display("UT: reuse blocked %0d waiters %0d", completed == 0,
                 barrier_value.get_num_waiters());
        barrier_value.wait_for(); completed[2] = 1;
      end
    join
    $display("UT: reuse all_done %0d waiters %0d", completed == 7,
             barrier_value.get_num_waiters());

    $finish;
  end
  initial begin #60; $fatal(1, "synchronization watchdog expired"); end
endmodule
