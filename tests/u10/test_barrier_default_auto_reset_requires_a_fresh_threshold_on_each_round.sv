/*
:name: test_barrier_default_auto_reset_requires_a_fresh_threshold_on_each_round
:description: barrier default auto-reset releases all waiters and requires the threshold again (IEEE 1800.2-2020 Section 10.3.2.4)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.3.2.4 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_barrier_default_auto_reset_requires_a_fresh_threshold_on_each_round.expected
*/
// What it checks:
// 1. A barrier blocks callers until the configured number reach the
//    synchronization point, then releases them all.
// 2. A barrier automatically rearms after reaching its threshold by default.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.3.2.2 (UVM-BARRIER-THRESHOLD-GATE) gives rule 1 above.
//    Setup: Two processes wait at a threshold of three, then the third
//    arrives. Expected: Two waiters remain blocked before the last arrival;
//    all three complete afterward.
// 2. 1800.2-2020 10.3.2.4 (UVM-BARRIER-DEFAULT-AUTO-RESET) gives rule 2 above.
//    Setup: Complete two consecutive rounds with three participants each
//    without setting auto-reset. Expected: Both rounds require a fresh third
//    participant and finish with zero pending waiters.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive delays establish waiting states. The fixtures do not require a
// particular order among processes released at the same synchronization point.
module test_barrier_default_auto_reset_requires_a_fresh_threshold_on_each_round;
  import uvm_pkg::*;
  typedef bit [31:0] word_t;
  uvm_barrier barrier_value;
  bit [2:0] completed = 0;
  initial begin

    barrier_value = new("barrier_value", 3);
    for (int round = 1; round <= 2; round++) begin
      completed = 0;
      fork
        begin barrier_value.wait_for(); completed[0] = 1; end
        begin barrier_value.wait_for(); completed[1] = 1; end
        begin
          #1;
          $display("UT: round %0d blocked %0d waiters %0d threshold %0d", round,
                   completed == 0, barrier_value.get_num_waiters(), barrier_value.get_threshold());
          barrier_value.wait_for(); completed[2] = 1;
        end
      join
      $display("UT: round %0d all_done %0d waiters %0d", round, completed == 7,
               barrier_value.get_num_waiters());
      #1;
    end

    $finish;
  end
  initial begin #60; $fatal(1, "synchronization watchdog expired"); end
endmodule
