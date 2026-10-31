/*
:name: test_packer_negative_real_and_zero_time_round_trip
:description: negative real and zero-valued fields retain their values after packing (IEEE 1800.2-2020 Section 16.5.4.6)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.6 16.5.4.7 16.5.4.14 16.5.4.15
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_negative_real_and_zero_time_round_trip.expected
*/
// Mixed fields include a negative exactly representable real, zero time,
// and zero real. Reading them back checks their order and value boundaries.

module test_packer_negative_real_and_zero_time_round_trip;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    uvm_packer packer = new;
    real negative_value;
    time zero_time;
    real zero_real;
    packer.pack_real(-2.25);
    packer.pack_time(0);
    packer.pack_real(0.0);
    negative_value = packer.unpack_real();
    zero_time = packer.unpack_time();
    zero_real = packer.unpack_real();
    $display("UT: negative %0d zero_time %0d zero_real %0d", negative_value == -2.25,
             zero_time == 0, zero_real == 0.0);
    $finish;
  end
endmodule
