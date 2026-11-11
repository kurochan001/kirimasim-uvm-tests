/*
:name: test_tlm2_time_scaled_increment_decrement_and_realtime_agree
:description: TLM 2 canonical time uses the uvm_time alias and prescribed time operations (IEEE 1800.2-2020 Section 12.3.9)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.9 5.6.2.5 5.6.2.6 5.6.2.7 5.6.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_time_scaled_increment_decrement_and_realtime_agree.expected
*/
// What it checks:
// Scaled increments, decrements and realtime queries represent consistent
// canonical values.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.6.2.6 (UVM-TLM-TIME-SCALED-ARITHMETIC) gives the rule above.
// Setup: Use a legal 100-second scale, add two plus three units, then subtract
// two. Expected: Canonical and realtime views agree at five then three units.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use 100 seconds as the scale literal, covering every legal time unit
// without a zero-valued scale. Express inputs in caller units using that
// literal and supply seconds explicitly. Values stay positive and exact
// in canonical ticks; no simulation delay or default time unit is assumed.

module test_tlm2_time_scaled_increment_decrement_and_realtime_agree;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit close_to(real actual, real wanted);
    real difference;
    difference = actual - wanted;
    if (difference < 0.0) difference = -difference;
    return difference <= 1.0e-12 * (wanted + 1.0);
  endfunction
  initial begin
    automatic uvm_tlm_time value = new("value", 1.0e-9);
    value.incr(2.0 * real'(100s), 100s, 100.0);
    value.incr(3.0 * real'(100s), 100s, 100.0);
    $display("UT: accumulated %0d realtime %0d", close_to(value.get_abstime(100.0), 5.0),
             close_to(value.get_realtime(100s, 100.0), 5.0 * real'(100s)));
    value.decr(2.0 * real'(100s), 100s, 100.0);
    $display("UT: decremented %0d realtime %0d", close_to(value.get_abstime(100.0), 3.0),
             close_to(value.get_realtime(100s, 100.0), 3.0 * real'(100s)));
    $finish;
  end
endmodule
