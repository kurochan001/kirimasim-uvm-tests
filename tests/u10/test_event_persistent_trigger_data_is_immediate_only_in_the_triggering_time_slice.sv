/*
:name: test_event_persistent_trigger_data_is_immediate_only_in_the_triggering_time_slice
:description: persistent event waiting returns after a same-slice trigger but blocks in a later slice (IEEE 1800.2-2020 Section 10.1.2.2.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.2.2.3 10.1.1.2.5 10.1.2.2.4 10.1.2.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_persistent_trigger_data_is_immediate_only_in_the_triggering_time_slice.expected
*/
// What it checks:
// Persistent trigger-data waiting accepts an earlier trigger in the same time
// slice but not an old slice.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.1.2.2.3 (UVM-EVENT-PERSISTENT-TRIGGER-DATA) gives the rule
// above. Setup: Call after a same-slice trigger, then establish a new wait in
// a later time slice. Expected: The same-slice call immediately returns 17;
// the later wait blocks until new data 73 arrives.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive delays establish waiting states. The fixtures do not require a
// particular order among processes released at the same synchronization point.
module test_event_persistent_trigger_data_is_immediate_only_in_the_triggering_time_slice;
  import uvm_pkg::*;
  typedef bit [31:0] word_t;
  uvm_event#(word_t) event_value;
  bit returned = 0;
  word_t data;
  time before_wait;
  initial begin

    event_value = new("event_value");
    #1; event_value.trigger(17); before_wait = $time;
    event_value.wait_ptrigger_data(data);
    $display("UT: same_slice immediate %0d data %0d", $time == before_wait, data);
    #1;
    fork
      begin event_value.wait_ptrigger_data(data); returned = 1; end
      begin #1; $display("UT: later_slice_wait %0d", !returned); event_value.trigger(73); end
    join
    $display("UT: fresh returned %0d data %0d latest %0d", returned, data,
             event_value.get_trigger_data());

    $finish;
  end
  initial begin #60; $fatal(1, "synchronization watchdog expired"); end
endmodule
