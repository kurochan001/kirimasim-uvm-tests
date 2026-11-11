/*
:name: test_reg_backdoor_watch_dispatch_1_90
:description: reg backdoor watch dispatch 1 checks independently derived manager or printed backdoor contracts
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.6.12 18.4.1 1800-2023 6.21 8.20 9.2 9.4
:uvm: 2020.3.1
:files: helpers90_watch/watch_fixture90.svh
:incdirs: helpers90_watch
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_backdoor_watch_dispatch_1_90.expected
*/
// What it checks:
// The printed register backdoor_watch virtual task is callable through
// register base receivers and dispatches the selected monitoring override.
//
// Variant: Inputs 0 and 1 swap the order in which the two registers are
// watched.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.6.12 (UVM-REG-BACKDOOR-WATCH-VIRTUAL-DISPATCH-90) gives the
// rule above. Setup: Use two original concrete register subtypes through exact
// uvm_reg base receivers. Write inputs alternate descriptor
// values/receivers;watch inputs monitor two original testbench variables with
// positive-time changes in opposite orders and an unrelated-variable control.
// Expected: Selected original task bodies execute with preserved
// descriptor/receiver identity;write observations check original
// storage/status and watch observations check selected blocking/return times.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original override waits on testbench HDL variables through the printed base
// task. Its body is setup; no default watch algorithm or complete change-
// monitoring behavior is certified.
module test_reg_backdoor_watch_dispatch_1_90;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  localparam int MODE=1;
  localparam int LAYOUT=1;
  localparam string CASE_NAME="reg_backdoor_watch_dispatch_1";
  `include "watch_fixture90.svh"
  initial begin #5000; $fatal(1,"manager/backdoor90 watchdog"); end
endmodule
