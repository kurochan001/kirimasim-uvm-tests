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
// What it checks:
// 1. Canonical time exposes its default and explicit instance names.
// 2. The canonical time class is constructible with the declared selected
//    parameters.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.6.2.3 (UVM-BASE-AUDIT-TIME-NAMES) gives rule 1 above.
//    Setup: Use a module with explicit 1-ps units/precision, legal 1-ns/1-ps
//    scale literals and a one-picosecond canonical resolution. Expected: The
//    default name is uvm_time and the peer retains peer61.
// 2. 1800.2-2020 5.6.1 (UVM-BASE-AUDIT-TIME-DECLARATION) gives rule 2 above.
//    Setup: Use a module with explicit 1-ps units/precision, legal 1-ns/1-ps
//    scale literals and a one-picosecond canonical resolution. Expected:
//    Omitted/named constructions and the initial zero absolute value are
//    available.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
