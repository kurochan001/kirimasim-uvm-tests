/*
:name: test_barrier_lowering_threshold_below_the_waiter_count_releases_existing_waits
:description: lowering a barrier threshold below the pending count releases waiters and keeps the new setting (IEEE 1800.2-2020 Section 10.3.2.6)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.3.2.6 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_barrier_lowering_threshold_below_the_waiter_count_releases_existing_waits.expected
*/
// Positive delays establish waiting states. The fixtures do not require a
// particular order among processes released at the same synchronization point.
module test_barrier_lowering_threshold_below_the_waiter_count_releases_existing_waits;
  import uvm_pkg::*;
  typedef bit [31:0] word_t;
  uvm_barrier barrier_value;
  bit [1:0] completed = 0;
  initial begin

    barrier_value = new("barrier_value", 4);
    fork
      begin barrier_value.wait_for(); completed[0] = 1; end
      begin barrier_value.wait_for(); completed[1] = 1; end
      begin
        #1;
        $display("UT: before blocked %0d waiters %0d threshold %0d", completed == 0,
                 barrier_value.get_num_waiters(), barrier_value.get_threshold());
        barrier_value.set_threshold(1);
      end
    join
    $display("UT: after all_done %0d waiters %0d threshold %0d", completed == 3,
             barrier_value.get_num_waiters(), barrier_value.get_threshold());
    barrier_value.wait_for();
    $display("UT: singleton_round waiters %0d threshold %0d", barrier_value.get_num_waiters(),
             barrier_value.get_threshold());

    $finish;
  end
  initial begin #60; $fatal(1, "synchronization watchdog expired"); end
endmodule
