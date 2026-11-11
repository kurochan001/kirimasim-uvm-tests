/*
:name: test_reg_frontdoor_get_multiple_replace_first_87
:description: reg frontdoor get multiple replace first observes standard access behavior with independent modeled storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.5.1 18.4.5.2 18.4.4.10 18.4.2.2 18.5.3.2 18.2.3.3 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.3 1800-2023 6.21 8.20 9.3.2 9.7
:uvm: 2020.3.1
:files: helpers87/frontdoor_query_fixture87.svh
:incdirs: helpers87
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=test87
:expected_exit: 0
:expected_stdout: @test_reg_frontdoor_get_multiple_replace_first_87.expected
*/
// What it checks:
// It is a control: it supports the setup or conditions of this duty, which
// other tests check directly:
// Register get_frontdoor returns null when no user-defined frontdoor is
// associated with the selected map.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.5.1 (UVM-ACCESS-REG-FRONTDOOR-NONE-87) gives the rule
// above. Setup: Independent16-bit register/frontdoor storage with single-map
// omitted/explicit getters and two-map explicit selections. Valid non-null
// variants check initial null getters, installation, replacement, debug
// arguments, independent peer/other map and restoration. Four separate
// original null-setter inputs use a disputed null-as-clear setup and are
// control-only, not direct evidence of a mandatory removal API. Expected:
// Initial unconfigured getter handles are null. Non-null
// installation/replacement/restoration selects the expected original provider;
// actual read values, map/peer isolation and debug-argument invariance are
// preserved. The disputed null-setter probe retains its separate expected null
// observation without deriving mandatory clearing from the getter alone.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independent original testbench storage; no HDL or physical bus protocol.
module test_reg_frontdoor_get_multiple_replace_first_87;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=2;
  localparam string CASE_NAME="reg_frontdoor_get_multiple_replace_first";
  `include "frontdoor_query_fixture87.svh"
  initial run_test("test87");
  initial begin #5000; $fatal(1,"access87 watchdog"); end
endmodule
