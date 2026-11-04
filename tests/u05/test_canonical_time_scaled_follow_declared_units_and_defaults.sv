/*
:name: test_canonical_time_scaled_follow_declared_units_and_defaults
:description: Canonical time scaled uses positive values and selected scales
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.6.2.5 5.6.2.7 5.6.2.8 5.6 5.6.2.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_canonical_time_scaled_follow_declared_units_and_defaults.expected
*/
// Arguments and get_realtime results use caller units (ps here).
// 2.5 ns minus 500 ps is 2000 ps; get_abstime uses explicit seconds.
module test_canonical_time_scaled_follow_declared_units_and_defaults;
  timeunit 1ps; timeprecision 1ps;
  import uvm_pkg::*;
  initial begin
    uvm_time value,peer;
    real result;
    value=new("time61",1.0e-12);
    value.incr(2.5*real'(1ns),1ns); value.decr(500.0*real'(1ps),1ps,1.0e-12);
    result=value.get_realtime(1ns);
    $display("UT: time_scaled caller_units %0d picoseconds %0d",
      result>1999.999999 && result<2000.000001,
      value.get_abstime(1.0e-12)>1999.999999 && value.get_abstime(1.0e-12)<2000.000001);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
