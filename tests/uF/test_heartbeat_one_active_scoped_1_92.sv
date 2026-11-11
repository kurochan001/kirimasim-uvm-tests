/*
:name: test_heartbeat_one_active_scoped_1_92
:description: heartbeat one active 1 checks selected mode effects through original public-API observations
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.11 10.6 10.6.2.1 10.6.2.2 10.6.2.3 10.6.2.7 10.5.1.3.3 10.5.1.3.4 10.5.1.5.3 6.6.3 1800-2023 6.21 8.20 8.21 9.2 9.4 18.5 18.4.2
:uvm: 2020.3.1
:files: helpers92_heartbeat_scoped/heartbeat_fixture92.svh
:incdirs: helpers92_heartbeat_scoped
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_heartbeat_one_active_scoped_1_92.expected
*/
// What it checks:
// It is a control: it supports the setup or conditions of this duty, which
// other tests check directly:
// UVM_ONE_ACTIVE accepts exactly one tracked component participating in the
// selected window.
//
// Variant: The inputs alternate which actor is active in each window: input 0
// starts with the first actor and input 1 with the second.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.2.11 (UVM-PKG-HEARTBEAT-MODE-ONE-92) gives the rule above.
// Setup: Two original histories monitor actor_a and actor_b through a chosen
// synchronizing objection. Three positive-time windows contain repeated
// balanced activity from selected tracked actors and from an untracked
// outsider. A context-bound original catcher requests termination on a nonINFO
// report;no post-failure state or recovery is asserted. An unstarted peer
// retains its explicitly selected mode. Separate controls remove only the
// outsider activity and retain the tracked actor windows. Expected:
// Alternating one tracked actor per window may raise/drop multiple counts
// while untracked outsider activity does not add a monitored participant;all
// selected windows remain quiet.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Additional-premise control removes only untracked outsider activity.
// Original positive-time heartbeat windows observe selected tracked components
// and an untracked outsider. Catch the first non-INFO report and terminate
// without assuming severity, exact text, count or recovery. NO_HB_MODE disable
// through an explicit argument is a qualified F.2.11 reading, distinct from
// the 10.6.2.2 query-default reading; preserve both interpretations and older
// query inputs.
module test_heartbeat_one_active_scoped_1_92;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=1;
  localparam int HB_KIND=1;
  localparam uvm_heartbeat_modes SELECT_MODE=UVM_ONE_ACTIVE;
  localparam string CASE_NAME="heartbeat_one_active_scoped_1";
  `include "heartbeat_fixture92.svh"
  initial begin #5000; $fatal(1,"mode-window92 watchdog"); end
endmodule
