/*
:name: test_root_guard_error_in_end_of_elaboration_88
:description: root guard error in end of elaboration checks independently derived public observations
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7.3.6 F.7 F.7.3.1 F.7.2.2 6.5.1.2.6 6.6.5 6.6.3.2 6.3.3.3 13.1.4.1.1 13.1.4.1.3 13.1.4.1.4 9.8.1.3 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:files: helpers88/guard_fixture88.svh
:incdirs: helpers88
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_root_guard_error_in_end_of_elaboration_88.expected
*/
// What it checks:
// The root end-of-elaboration error check generates a fatal for existing
// default-server errors before start-of-simulation.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.7.3.6 (UVM-ROOT-EOE-ERROR-GUARD-88) gives the rule above.
// Setup: Inject an original report error during build or child
// end-of-elaboration. The real root and default report server are used. A
// root-only fatal catcher observes severity and returns THROW without
// modifying the message/action. The build control only requires fatal before
// start-of-simulation; the late-child input directly tests the printed
// bottom-up end-of-elaboration/API grouping. The original build probe that
// additionally requires child EOE before fatal is control-only. Expected: An
// original error is recorded and a fatal is observed before
// start-of-simulation; the selected late-child grouping retains its separate
// expectation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_root_guard_error_in_end_of_elaboration_88;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam string CASE_NAME="root_guard_error_in_end_of_elaboration";
  localparam int MODE=1;
  `include "guard_fixture88.svh"
  initial begin #5000; $fatal(1,"root or predictor88 watchdog"); end
endmodule
