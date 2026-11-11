/*
:name: test_predictor_check_registered_pending_little_2_registers_88
:description: predictor check pending little 2 registers checks independently derived public observations
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.3.3.3 9.8.1.7 B.2.1.2 19.3.2.1 19.3.2.2 19.3.2.3 19.3.2.4 19.2.1.2.5 19.2.1.2.6 18.4.4.15 18.4.2.2 18.5.3.2 18.2.3.3 18.2.3.6 18.2.5.2 6.6.5 6.6.3.2 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:files: helpers88_registered/predictor_check_fixture88.svh
:incdirs: helpers88_registered
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_predictor_check_registered_pending_little_2_registers_88.expected
*/
// What it checks:
// Under the observable-check interpretation, predictor check_phase detects
// queued incomplete register transfers separately from a completed control.
//
// How the expected output follows from the standard:
// 1800.2-2020 19.3.3.3 (UVM-PREDICTOR-PENDING-CHECK-88) gives the rule above.
// Setup: Original registered packet controls use two independent
// predictors,blocks,maps and 32-bit registers behind16-bit little/big-endian
// observations. One predictor completes both registers; the other receives
// only first beats for1/2registers. The actual bottom-up check phase runs
// before the parent check observer. All predictor reports are captured as
// CAUGHT without fixing severity/ID/text/count. Four bare unregistered packet
// inputs stay unchanged as build-level control-only probes of the library
// registration dependency, not IEEE-required registration. Expected: The
// completed model retains both full mirrors and two publications without new
// error/fatal; the incomplete model has no publication and produces some
// report during actual check phase.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_predictor_check_registered_pending_little_2_registers_88;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam string CASE_NAME="predictor_check_registered_pending_little_2_registers";
  localparam bit BIG_ENDIAN=0;
  localparam int PENDING_REGISTERS=2;
  `include "predictor_check_fixture88.svh"
  initial begin #5000; $fatal(1,"root or predictor88 watchdog"); end
endmodule
