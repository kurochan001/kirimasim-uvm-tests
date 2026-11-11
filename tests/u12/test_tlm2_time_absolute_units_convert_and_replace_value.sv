/*
:name: test_tlm2_time_absolute_units_convert_and_replace_value
:description: TLM 2 canonical time uses the uvm_time alias and prescribed time operations (IEEE 1800.2-2020 Section 12.3.9)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.9 5.6.2.8 5.6.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_time_absolute_units_convert_and_replace_value.expected
*/
// What it checks:
// Absolute time assignment replaces the old value and supports unit
// conversion.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.6.2.9 (UVM-TLM-TIME-ABSOLUTE-CONVERSION-REPLACEMENT) gives the
// rule above. Setup: Set 2.5 microseconds, query nanoseconds, then assign
// seven nanoseconds. Expected: Queries return 2.5 microseconds/2500
// nanoseconds, then seven nanoseconds.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Set absolute time in microseconds and observe both microseconds and
// nanoseconds. A later absolute assignment replaces the previous value.
// Compare reals with a small relative tolerance, not formatting or bits.

module test_tlm2_time_absolute_units_convert_and_replace_value;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit close_to(real actual, real wanted);
    real difference;
    difference = actual - wanted;
    if (difference < 0.0) difference = -difference;
    return difference <= 1.0e-12 * (wanted + 1.0);
  endfunction
  initial begin
    automatic uvm_tlm_time value = new("value", 1.0e-12);
    value.set_abstime(2.5, 1.0e-6);
    $display("UT: microseconds %0d nanoseconds %0d", close_to(value.get_abstime(1.0e-6), 2.5),
             close_to(value.get_abstime(1.0e-9), 2500.0));
    value.set_abstime(7.0, 1.0e-9);
    $display("UT: replaced %0d", close_to(value.get_abstime(1.0e-9), 7.0));
    $finish;
  end
endmodule
