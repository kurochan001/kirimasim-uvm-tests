/*
:name: test_canonical_time_decrements_follow_declared_units_and_defaults
:description: Canonical time decrements uses positive values and selected scales
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.6.2.7 5.6.2.8 5.6.2.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_canonical_time_decrements_follow_declared_units_and_defaults.expected
*/
// Keep the standard omitted secs default; a separate explicit-seconds
// fixture isolates arithmetic from an incompatible implementation default.
module test_canonical_time_decrements_follow_declared_units_and_defaults;
  timeunit 1ps; timeprecision 1ps;
  import uvm_pkg::*;
  initial begin
    uvm_time value,peer;
    real result;
    value=new("time61",1.0e-12); peer=new("peer61",1.0e-12);
    value.incr(5.0*real'(1ns),1ns); peer.incr(7.0*real'(1ns),1ns);
    value.decr(2.0*real'(1ns),1ns); value.decr(1.0*real'(1ns),1ns);
    result=value.get_abstime(1.0e-9);
    $display("UT: time_decrements selected %0d peer %0d",
      result>1.999999 && result<2.000001,
      peer.get_abstime(1.0e-9)>6.999999 && peer.get_abstime(1.0e-9)<7.000001);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
