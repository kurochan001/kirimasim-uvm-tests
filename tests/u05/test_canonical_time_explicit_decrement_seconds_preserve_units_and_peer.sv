/*
:name: test_canonical_time_explicit_decrement_seconds_preserve_units_and_peer
:description: Canonical time decrements uses positive values and selected scales
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.6.2.7 5.6.2.8 5.6.2.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_canonical_time_explicit_decrement_seconds_preserve_units_and_peer.expected
*/
// What it checks:
// 1. Explicit seconds decrement the selected canonical time and preserve a
//    peer.
// 2. Absolute getters express the selected canonical value in requested
//    seconds units.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.6.2.7 (UVM-BASE-AUDIT-TIME-DECREMENT-EXPLICIT) gives rule 1
//    above. Setup: Use a module with explicit 1-ps units/precision, legal
//    1-ns/1-ps scale literals and a one-picosecond canonical resolution.
//    Expected: Five minus two minus one gives two nanoseconds; the peer
//    remains seven.
// 2. 1800.2-2020 5.6.2.8 (UVM-BASE-AUDIT-TIME-ABSOLUTE) gives rule 2 above.
//    Setup: Use a module with explicit 1-ps units/precision, legal 1-ns/1-ps
//    scale literals and a one-picosecond canonical resolution. Expected: The
//    selected ps/ns observations agree with the independently calculated
//    values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit seconds isolate arithmetic from the separate omitted-default probe.
module test_canonical_time_explicit_decrement_seconds_preserve_units_and_peer;
  timeunit 1ps; timeprecision 1ps;
  import uvm_pkg::*;
  initial begin
    uvm_time value,peer;
    real result;
    value=new("time61",1.0e-12); peer=new("peer61",1.0e-12);
    value.incr(5.0*real'(1ns),1ns); peer.incr(7.0*real'(1ns),1ns);
    value.decr(2.0*real'(1ns),1ns,1.0e-9); value.decr(1.0*real'(1ns),1ns,1.0e-9);
    result=value.get_abstime(1.0e-9);
    $display("UT: time_decrements selected %0d peer %0d",
      result>1.999999 && result<2.000001,
      peer.get_abstime(1.0e-9)>6.999999 && peer.get_abstime(1.0e-9)<7.000001);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
