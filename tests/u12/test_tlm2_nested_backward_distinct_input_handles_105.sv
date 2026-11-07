/*
:name: test_tlm2_nested_backward_distinct_input_handles_105
:description: nested backward transport retains input handles and caller context (IEEE 1800.2-2020 Section 12.3.2.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.2.2.2 12.3.2.2 12.3.2.1 12.3.2 12.3.6.3 12.3.7.3 12.3.8.3 12.3.3.2 1800-2023 6.21 8.4 13.5.1 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers105_transport/transport105.svh
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_tlm2_nested_backward_distinct_input_handles_105.expected
*/
// Two exports route outer and nested calls through the same resolved port.
// Endpoint input-handle rebinding must retain the caller's original handles.
// Shared/distinct objects expose aliasing and peer isolation independently.
// Nonblocking custom phase properties expose ref updates before return.
// Original endpoint arithmetic is setup, not a required protocol algorithm.
module test_tlm2_nested_backward_distinct_input_handles_105;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int KIND105 = 2;
  localparam bit SHARED105 = 0;
  `include "transport105.svh"
  initial run_test();
  initial begin #100; $fatal(1, "nested transport watchdog expired"); end
endmodule
