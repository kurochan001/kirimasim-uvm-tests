/*
:name: test_pkg_phase_kinds_1_91
:description: pkg phase kinds 1 observes named selections through original public-API fixtures
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.5.1 9.3.1.3.1 9.3.1.3.2 9.3.1.4.4 9.3.1.5.1 9.3.1.6.1 9.3.1.6.2 9.3.1.6.6 9.4.1 9.4.2.1 9.6.2.1 9.6.2.2 9.6.2.3 9.7.2.1 9.7.2.2 9.7.2.3 13.1.4.4.2 1800-2023 6.21 8.20 8.21 9.2 9.4 11.4
:uvm: 2020.3.1
:files: helpers91_phase/phase_fixture91.svh
:incdirs: helpers91_phase
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_phase_kinds_1_91.expected
*/
// What it checks:
// Under the strict schedule-local reading,a scoped lookup for a repeated IMP
// selects the node of that receiver schedule after domain attachment.
//
// Variant: Inputs 0 and 1 swap which of the two schedules is queried and which
// is the peer.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.3.1.4.4 (UVM-PHASE-FIND-SHARED-DOMAIN-SCHEDULE-READING-91)
// gives the rule above. Setup: Both schedules contain the same two
// implementation objects and are attached to one domain. Original inputs use
// the default stay_in_scope and compare returned node/parent identities.
// Separate prescoped sources capture nodes before attachment and only supply
// controls for this original lookup premise. Expected: Each original schedule
// lookup identifies its own distinct node and parent,while both retain the
// enclosing domain and actual traversal context.
// It also supports, as a control, the setup or conditions of
// UVM-PKG-PHASE-KIND-DESIGNATORS-91, UVM-PKG-PHASE-KIND-IMP-DISPATCH-91,
// UVM-PKG-PHASE-KIND-NODE-CONTEXT-91, UVM-PKG-PHASE-KIND-SCHEDULE-GROUP-91,
// UVM-PKG-PHASE-KIND-DOMAIN-OWNER-91.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Actual IMP traversal uses separately created NODE contexts in two schedules
// of the component domain. Only ancestor ordering is checked. get_imp
// wording,automatic scheduling and domain parallel execution remain open.
module test_pkg_phase_kinds_1_91;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=1;
  localparam string CASE_NAME="pkg_phase_kinds_1";
  `include "phase_fixture91.svh"
  initial begin #5000; $fatal(1,"typed role/event/topology91 watchdog"); end
endmodule
