/*
:name: test_tlm2_time_standard_default_resolution_api_constructs_delay
:description: TLM 2 canonical time uses the uvm_time alias and prescribed time operations (IEEE 1800.2-2020 Section 12.3.9)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.9 5.6.2.2 5.6.2.1 5.6.2.8 5.6.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_time_standard_default_resolution_api_constructs_delay.expected
*/
// Use the standard default-resolution setter before constructing a delay
// and restore the standard default afterwards. The pinned library lacks
// this API spelling, so this normative case is spec-only and cannot build.
// The round trip does not prescribe sub-resolution rounding.

module test_tlm2_time_standard_default_resolution_api_constructs_delay;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit close_to(real actual, real wanted);
    real difference;
    difference = actual - wanted;
    if (difference < 0.0) difference = -difference;
    return difference <= 1.0e-12 * (wanted + 1.0);
  endfunction
  initial begin
    automatic uvm_tlm_time value;
    uvm_time::set_default_time_resolution(1.0e-9);
    value = new("configured");
    value.set_abstime(7.0, 1.0e-9);
    $display("UT: configured_roundtrip %0d", close_to(value.get_abstime(1.0e-9), 7.0));
    uvm_time::set_default_time_resolution(1.0e-12);
    $finish;
  end
endmodule
