/*
:name: test_tlm2_time_reset_is_local_across_explicit_resolutions
:description: TLM 2 canonical time uses the uvm_time alias and prescribed time operations (IEEE 1800.2-2020 Section 12.3.9)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.9 5.6.2.1 5.6.2.4 5.6.2.8 5.6.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_time_reset_is_local_across_explicit_resolutions.expected
*/
// Use two explicit canonical resolutions with exactly representable
// values. Reset only one object and keep the other value. No rounding
// policy for a sub-resolution value is assumed.

module test_tlm2_time_reset_is_local_across_explicit_resolutions;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit close_to(real actual, real wanted);
    real difference;
    difference = actual - wanted;
    if (difference < 0.0) difference = -difference;
    return difference <= 1.0e-12 * (wanted + 1.0);
  endfunction
  initial begin
    automatic uvm_tlm_time first = new("first", 1.0e-9);
    automatic uvm_tlm_time second = new("second", 1.0e-12);
    first.set_abstime(12.0, 1.0e-9);
    second.set_abstime(12.0, 1.0e-9);
    $display("UT: equal_values %0d %0d distinct %0d", close_to(first.get_abstime(1.0e-9), 12.0),
             close_to(second.get_abstime(1.0e-9), 12.0), first != second);
    first.reset();
    $display("UT: reset_local %0d %0d", close_to(first.get_abstime(1.0e-9), 0.0),
             close_to(second.get_abstime(1.0e-9), 12.0));
    $finish;
  end
endmodule
