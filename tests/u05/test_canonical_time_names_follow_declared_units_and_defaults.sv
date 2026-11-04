/*
:name: test_canonical_time_names_follow_declared_units_and_defaults
:description: Canonical time names uses positive values and selected scales
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.6.2.3 5.6.2.1 5.6.1 5.6 5.6.2.8 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_canonical_time_names_follow_declared_units_and_defaults.expected
*/
module test_canonical_time_names_follow_declared_units_and_defaults;
  timeunit 1ps; timeprecision 1ps;
  import uvm_pkg::*;
  initial begin
    uvm_time value,peer;
    real result;
    value=new(); peer=new("peer61",1.0e-12);
    $display("DETAIL: canonical default name <%s>",value.get_name());
    $display("UT: time_names default %0d explicit %0d initial_zero %0d",
      value.get_name()=="uvm_time",peer.get_name()=="peer61",value.get_abstime(1.0e-9)==0.0);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
