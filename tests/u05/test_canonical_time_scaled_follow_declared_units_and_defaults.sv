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
// What it checks:
// 1. Canonical time represents selected equivalent scaled/absolute values.
// 2. get_realtime returns the selected canonical value in caller units.
// 3. Absolute getters express the selected canonical value in requested
//    seconds units.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.6 (UVM-BASE-AUDIT-TIME-CANONICAL-ROLE) gives rule 1 above.
//    Setup: Use a module with explicit 1-ps units/precision, legal 1-ns/1-ps
//    scale literals and a one-picosecond canonical resolution. Expected: The
//    corrected 2.5 ns minus 500 ps operation yields 2000 caller ps and 2000
//    absolute ps.
// 2. 1800.2-2020 5.6.2.5 (UVM-BASE-AUDIT-TIME-REALTIME) gives rule 2 above.
//    Setup: Use a module with explicit 1-ps units/precision, legal 1-ns/1-ps
//    scale literals and a one-picosecond canonical resolution. Expected: A
//    1-ps caller observes approximately 2000 after the selected operations.
// 3. 1800.2-2020 5.6.2.8 (UVM-BASE-AUDIT-TIME-ABSOLUTE) gives rule 3 above.
//    Setup: Use a module with explicit 1-ps units/precision, legal 1-ns/1-ps
//    scale literals and a one-picosecond canonical resolution. Expected: The
//    selected ps/ns observations agree with the independently calculated
//    values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
