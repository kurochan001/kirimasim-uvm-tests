/*
:name: test_root_finish_default_after_phases_88
:description: root finish default after phases checks independently derived public observations
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7.3.4 F.7.3.4 F.7.3.5 F.7.3.1 F.7.2.2 13.1.4.2.1 13.1.4.1.8 9.8.1 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:files: helpers88/finish_fixture88.svh
:incdirs: helpers88
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_root_finish_default_after_phases_88.expected
*/
// What it checks:
// It is a control: it supports the setup or conditions of this duty, which
// other tests check directly:
// Default or explicitly reenabled finish-on-completion terminates after the
// selected final phase before caller-owned positive-time activity.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.7.3.4 (UVM-ROOT-FINISH-AUTOMATIC-88) gives the rule above.
// Setup: Use the actual singleton root, default/latest getter histories and
// real run_test through a small component that raises an objection, waits
// positive time and reaches final_phase. Independent default/reenabled
// controls observe completion before a later positive-time marker while the
// watchdog still schedules future activity; caller-owned mode observes
// run_test return and an explicit later finish. The stricter original
// no-same-time-return probes are control-only, not the definition of the
// finish flag. Expected: The final-phase marker is present; no new
// positive-time marker occurs and no error/fatal accounts for termination.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_root_finish_default_after_phases_88;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam string CASE_NAME="root_finish_default_after_phases";
  localparam int MODE=1;
  `include "finish_fixture88.svh"
  initial begin #5000; $fatal(1,"root or predictor88 watchdog"); end
endmodule
