/*
:name: test_heartbeat_no_hb_mode_0_92
:description: heartbeat no hb mode 0 checks selected mode effects through original public-API observations
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.11 10.6 10.6.2.1 10.6.2.2 10.6.2.3 10.6.2.7 10.5.1.3.3 10.5.1.3.4 10.5.1.5.3 6.6.3 1800-2023 6.21 8.20 8.21 9.2 9.4 18.5 18.4.2
:uvm: 2020.3.1
:files: helpers92_heartbeat/heartbeat_fixture92.svh
:incdirs: helpers92_heartbeat
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_heartbeat_no_hb_mode_0_92.expected
*/
// What it checks:
// Under the literal disabled reading,explicit UVM_NO_HB_MODE selection
// disables heartbeat monitoring.
//
// Variant: Input 0 starts in UVM_ALL_ACTIVE mode with both actors active
// before the heartbeat is disabled; input 1 starts in UVM_ONE_ACTIVE mode with
// only the first actor active.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.2.11 (UVM-PKG-HEARTBEAT-NO-MODE-DISABLED-READING-92) gives the
// rule above. Setup: After one healthy ALL or ONE window,pass an explicit
// UVM_NO_HB_MODE argument and trigger two empty positive-time windows.
// Separate stop controls call the printed stop API instead of changing mode.
// Expected: The selected disabled value reads back and the empty windows emit
// no nonINFO report;the peer mode and balanced counts remain intact.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original positive-time heartbeat windows observe selected tracked components
// and an untracked outsider. Catch the first non-INFO report and terminate
// without assuming severity, exact text, count or recovery. NO_HB_MODE disable
// through an explicit argument is a qualified F.2.11 reading, distinct from
// the 10.6.2.2 query-default reading; preserve both interpretations and older
// query inputs.
module test_heartbeat_no_hb_mode_0_92;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=0;
  localparam int HB_KIND=3;
  localparam uvm_heartbeat_modes SELECT_MODE=UVM_NO_HB_MODE;
  localparam string CASE_NAME="heartbeat_no_hb_mode_0";
  `include "heartbeat_fixture92.svh"
  initial begin #5000; $fatal(1,"mode-window92 watchdog"); end
endmodule
