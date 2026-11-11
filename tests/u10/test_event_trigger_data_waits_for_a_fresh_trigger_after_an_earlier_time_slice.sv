/*
:name: test_event_trigger_data_waits_for_a_fresh_trigger_after_an_earlier_time_slice
:description: event trigger-data waits ignore earlier time slices and return fresh supplied data (IEEE 1800.2-2020 Section 10.1.2.2.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.2.2.2 10.1.1.2.4 10.1.1.2.6 10.1.1.2.7 10.1.2.2.4 10.1.2.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_trigger_data_waits_for_a_fresh_trigger_after_an_earlier_time_slice.expected
*/
// What it checks:
// Event wait_trigger_data returns data from a new trigger after an older time
// slice.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.1.2.2.2 (UVM-EVENT-FRESH-TRIGGER-DATA) gives the rule above.
// Setup: Trigger data 17, advance time, start a wait and then trigger data 42.
// Expected: The earlier on-state/data does not release the wait; the new
// trigger returns 42 and updates trigger time.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive delays establish waiting states. The fixtures do not require a
// particular order among processes released at the same synchronization point.
module test_event_trigger_data_waits_for_a_fresh_trigger_after_an_earlier_time_slice;
  import uvm_pkg::*;
  typedef bit [31:0] word_t;
  uvm_event#(word_t) event_value;
  bit returned = 0;
  word_t data;
  time trigger_time;
  initial begin

    event_value = new("event_value"); event_value.trigger(17);
    #1;
    fork
      begin event_value.wait_trigger_data(data); returned = 1; end
      begin
        #1;
        $display("UT: waiting_fresh %0d still_on %0d old_data %0d", !returned,
                 event_value.is_on(), event_value.get_trigger_data());
        trigger_time = $time; event_value.trigger(42);
      end
    join
    $display("UT: returned %0d data %0d latest %0d trigger_time %0d", returned, data,
             event_value.get_trigger_data(), event_value.get_trigger_time() == trigger_time);

    $finish;
  end
  initial begin #60; $fatal(1, "synchronization watchdog expired"); end
endmodule
