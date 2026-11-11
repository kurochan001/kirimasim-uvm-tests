/*
:name: test_tlm2_nested_blocking_distinct_input_handles_105
:description: nested blocking transport retains input handles and caller context (IEEE 1800.2-2020 Section 12.3.2.2.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.2.2.3 12.3.2.2 12.3.2.1 12.3.2 12.3.6.1 12.3.7.1 12.3.8.1 12.3.3.2 1800-2023 6.21 8.4 13.5.1 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers105_transport/transport105.svh
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_tlm2_nested_blocking_distinct_input_handles_105.expected
*/
// What it checks:
// The input object-handle forms of the TLM 2 transport methods retain caller
// bindings when a callee rebinds its formal handles.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.2.2 (UVM-TLM2-TRANSPORT-INPUT-HANDLE-REBINDING-105) gives
// the rule above. Setup: Call blocking, forward or backward transport through
// a resolved ordinary port/two-export/imp route. Reenter the same port before
// the outer call returns, using shared or distinct input objects and two
// successive rounds. Mutate the supplied objects, rebind each endpoint formal
// to independent replacements and mutate those replacements. Expected:
// Original object mutations remain visible through the exact caller handles.
// Formal rebinding and replacement mutations do not replace caller handles or
// modify an unselected peer. The outer activation retains its own local
// replacements across the nested call, and both rounds retain their
// independently declared data and delay results.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Two exports route outer and nested calls through the same resolved port.
// Endpoint input-handle rebinding must retain the caller's original handles.
// Shared/distinct objects expose aliasing and peer isolation independently.
// Nonblocking custom phase properties expose ref updates before return.
// Original endpoint arithmetic is setup, not a required protocol algorithm.
module test_tlm2_nested_blocking_distinct_input_handles_105;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int KIND105 = 0;
  localparam bit SHARED105 = 0;
  `include "transport105.svh"
  initial run_test();
  initial begin #100; $fatal(1, "nested transport watchdog expired"); end
endmodule
