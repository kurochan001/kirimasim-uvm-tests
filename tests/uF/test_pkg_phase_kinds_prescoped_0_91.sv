/*
:name: test_pkg_phase_kinds_prescoped_0_91
:description: pkg phase kinds 0 observes named selections through original public-API fixtures
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.5.1 9.3.1.3.1 9.3.1.3.2 9.3.1.4.4 9.3.1.5.1 9.3.1.6.1 9.3.1.6.2 9.3.1.6.6 9.4.1 9.4.2.1 9.6.2.1 9.6.2.2 9.6.2.3 9.7.2.1 9.7.2.2 9.7.2.3 13.1.4.4.2 1800-2023 6.21 8.20 8.21 9.2 9.4 11.4
:uvm: 2020.3.1
:files: helpers91_phase_prescoped/phase_fixture91.svh
:incdirs: helpers91_phase_prescoped
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_phase_kinds_prescoped_0_91.expected
*/
// What it checks:
// 1. The phase-kind type supplies the named IMP,NODE,SCHEDULE and DOMAIN
//    designators.
// 2. A phase implementation supplies behavior for traversing the selected
//    component hierarchy.
// 3. A phase node supplies a distinct instance context within its containing
//    schedule.
// 4. A schedule identifies the container of its selected phase nodes.
// 5. A domain identifies the graph segment enclosing the selected schedules
//    and nodes.
//
// Variant: Inputs 0 and 1 swap which of the two schedules is queried and which
// is the peer.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.2.5.1 (UVM-PKG-PHASE-KIND-DESIGNATORS-91) gives rule 1
//    above. Setup: Two independent original inputs create topdown/bottomup IMP
//    objects and nodes in two schedules. They capture each isolated schedule
//    node before joining both schedules to the component domain,then check
//    types,parent/domain identities and manual selected-subtree traversal.
//    Original post-attachment lookup inputs remain separate controls for the
//    stricter scope interpretation. Expected: Actual selected
//    implementation,node,schedule and domain objects report their named
//    kinds;the unchanged explicit-constructor input supplies a separate
//    compatible type observation.
// 2. 1800.2-2020 F.2.5.1 (UVM-PKG-PHASE-KIND-IMP-DISPATCH-91) gives rule 2
//    above. Setup: Two independent original inputs create topdown/bottomup IMP
//    objects and nodes in two schedules. They capture each isolated schedule
//    node before joining both schedules to the component domain,then check
//    types,parent/domain identities and manual selected-subtree traversal.
//    Original post-attachment lookup inputs remain separate controls for the
//    stricter scope interpretation. Expected: Actual topdown and bottomup
//    implementation objects invoke the original callbacks over the selected
//    subtree in ancestor-consistent order with the supplied node context.
// 3. 1800.2-2020 F.2.5.1 (UVM-PKG-PHASE-KIND-NODE-CONTEXT-91) gives rule 3
//    above. Setup: Two independent original inputs create topdown/bottomup IMP
//    objects and nodes in two schedules. They capture each isolated schedule
//    node before joining both schedules to the component domain,then check
//    types,parent/domain identities and manual selected-subtree traversal.
//    Original post-attachment lookup inputs remain separate controls for the
//    stricter scope interpretation. Expected: Prescoped nodes for the repeated
//    implementation have distinct handles and selected parent schedules;manual
//    dispatch receives the selected node handle.
// 4. 1800.2-2020 F.2.5.1 (UVM-PKG-PHASE-KIND-SCHEDULE-GROUP-91) gives rule 4
//    above. Setup: Two independent original inputs create topdown/bottomup IMP
//    objects and nodes in two schedules. They capture each isolated schedule
//    node before joining both schedules to the component domain,then check
//    types,parent/domain identities and manual selected-subtree traversal.
//    Original post-attachment lookup inputs remain separate controls for the
//    stricter scope interpretation. Expected: Both named schedule objects
//    retain SCHEDULE kind and the independently captured nodes identify the
//    corresponding parent schedule.
// 5. 1800.2-2020 F.2.5.1 (UVM-PKG-PHASE-KIND-DOMAIN-OWNER-91) gives rule 5
//    above. Setup: Two independent original inputs create topdown/bottomup IMP
//    objects and nodes in two schedules. They capture each isolated schedule
//    node before joining both schedules to the component domain,then check
//    types,parent/domain identities and manual selected-subtree traversal.
//    Original post-attachment lookup inputs remain separate controls for the
//    stricter scope interpretation. Expected: The component domain reports
//    DOMAIN kind and both prescoped nodes report that enclosing owner after
//    attachment.
// It also supports, as a control, the setup or conditions of
// UVM-PHASE-FIND-SHARED-DOMAIN-SCHEDULE-READING-91.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Capture unambiguous per-schedule NODE handles before binding both schedules
// of the component domain. Only ancestor ordering is checked. get_imp
// wording,automatic scheduling and domain parallel execution remain open.
module test_pkg_phase_kinds_prescoped_0_91;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=0;
  localparam string CASE_NAME="pkg_phase_kinds_prescoped_0";
  `include "phase_fixture91.svh"
  initial begin #5000; $fatal(1,"typed role/event/topology91 watchdog"); end
endmodule
