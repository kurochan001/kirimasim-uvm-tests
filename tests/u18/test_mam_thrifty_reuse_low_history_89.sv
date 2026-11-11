/*
:name: test_mam_thrifty_reuse_low_history_89
:description: mam thrifty reuse low history observes independently derived enum effects and preserved controls
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.2.1 18.12.2.1 18.12.2.2 18.12.9.2.4 18.12.9.2.5 18.12.4.1 18.12.4.2 18.12.5.1 18.12.5.2 18.12.5.3 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 18.12.8.1 18.12.8.2.2 1800-2023 6.21 8.20 18.5
:uvm: 2020.3.1
:files: helpers89/mam_modes_fixture89.svh
:incdirs: helpers89
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_thrifty_reuse_low_history_89.expected
*/
// What it checks:
// THRIFTY reuses the unique released block when it provides the maximal
// possible reuse for the selected request.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.12.2.1 (UVM-MAM-THRIFTY-REUSE-89) gives the rule above.
// Setup: Explicit historical interpretation. In each of eight fresh32-location
// one-byte managers,a live4-location region remains reserved while another
// low/high4-location region is reserved and released. A
// default-policy4-location request follows. The qualified GREEDY reading
// consumes never-before-reserved space when available;the THRIFTY reading
// maximizes reuse of the released block. Per-request
// bounds,width,disjointness,held-region endpoints/membership and cleanup are
// checked without private history state. Expected: Every selected request is
// valid and meets its stated fresh/reuse preference while held regions remain
// unchanged and allocated until explicitly released.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_mam_thrifty_reuse_low_history_89;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=4;
  localparam string CASE_NAME="mam_thrifty_reuse_low_history";
  `include "mam_modes_fixture89.svh"
  initial begin #5000; $fatal(1,"allocation or ordering89 watchdog"); end
endmodule
