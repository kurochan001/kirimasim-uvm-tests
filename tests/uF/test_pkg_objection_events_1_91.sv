/*
:name: test_pkg_objection_events_1_91
:description: pkg objection events 1 observes named selections through original public-API fixtures
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.6 10.5.1.1 10.5.1.3.3 10.5.1.3.4 10.5.1.3.7 10.5.1.4.1 10.5.1.4.2 10.5.1.4.3 10.5.1.5.2 10.5.1.5.4 1800-2023 6.21 8.20 8.21 9.2 9.4 11.4
:uvm: 2020.3.1
:files: helpers91_objection/objection_fixture91.svh
:incdirs: helpers91_objection
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_objection_events_1_91.expected
*/
// What it checks:
// 1. An objection RAISED event identifies a raise for the selected object.
// 2. An objection DROPPED event identifies a drop,including a partial drop.
// 3. An objection ALL_DROPPED event identifies completion after the selected
//    count reaches zero.
//
// Variant: Input 0 drops the objection of the first source with a count of 2;
// input 1 that of the second source with a count of 3.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.2.6 (UVM-PKG-OBJECTION-EVENT-RAISED-91) gives rule 1 above.
//    Setup: Two inputs use opposite explicit noncomponent sources and positive
//    counts2/3. Three typed waiters are armed before raise,partial drop and
//    final drop. Drain is explicitly zero and the original all-dropped
//    callback delays in the wrapper scope. The selected source and an
//    independent objection/source peer are observed. Expected: Only the
//    corresponding event releases each selected waiter after its observed
//    callback work;partial drop does not release all-dropped,and final
//    completion sees count0 with the peer untouched.
// 2. 1800.2-2020 F.2.6 (UVM-PKG-OBJECTION-EVENT-DROPPED-91) gives rule 2
//    above. Setup: Two inputs use opposite explicit noncomponent sources and
//    positive counts2/3. Three typed waiters are armed before raise,partial
//    drop and final drop. Drain is explicitly zero and the original
//    all-dropped callback delays in the wrapper scope. The selected source and
//    an independent objection/source peer are observed. Expected: Only the
//    corresponding event releases each selected waiter after its observed
//    callback work;partial drop does not release all-dropped,and final
//    completion sees count0 with the peer untouched.
// 3. 1800.2-2020 F.2.6 (UVM-PKG-OBJECTION-EVENT-ALL-DROPPED-91) gives rule 3
//    above. Setup: Two inputs use opposite explicit noncomponent sources and
//    positive counts2/3. Three typed waiters are armed before raise,partial
//    drop and final drop. Drain is explicitly zero and the original
//    all-dropped callback delays in the wrapper scope. The selected source and
//    an independent objection/source peer are observed. Expected: Only the
//    corresponding event releases each selected waiter after its observed
//    callback work;partial drop does not release all-dropped,and final
//    completion sees count0 with the peer untouched.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Typed raised,dropped and all-dropped waiters observe the selected source
// with a partial drop and delayed original completion callback. Drain is
// explicitly zero;no cross-scope delay-unit conversion is assumed.
module test_pkg_objection_events_1_91;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=1;
  localparam string CASE_NAME="pkg_objection_events_1";
  `include "objection_fixture91.svh"
  initial begin #5000; $fatal(1,"typed role/event/topology91 watchdog"); end
endmodule
