/*
:name: test_pkg_wait_operators_0_91
:description: pkg wait operators 0 observes named selections through original public-API fixtures
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.5.3 9.3.1.1.3 9.3.1.3.1 9.3.1.4.1 9.3.1.8.3 F.2.5.2 1800-2023 6.21 8.20 8.21 9.2 9.4 11.4
:uvm: 2020.3.1
:files: helpers91_wait/wait_fixture91.svh
:incdirs: helpers91_wait
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_wait_operators_0_91.expected
*/
// What it checks:
// 1. UVM_EQ selects the equal relation for the selected phase-state wait.
// 2. UVM_NE selects the not equal relation for the selected phase-state wait.
// 3. UVM_LT selects the less than relation for the selected phase-state wait.
// 4. UVM_LTE selects the less than or equal relation for the selected
//    phase-state wait.
// 5. UVM_GT selects the greater than relation for the selected phase-state
//    wait.
// 6. UVM_GTE selects the greater than or equal relation for the selected
//    phase-state wait.
//
// Variant: Input 0 compares each wait operator against the initial phase
// state; input 1 against UVM_PHASE_DONE.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.2.5.3 (UVM-PKG-WAIT-OP-EQ-91) gives rule 1 above. Setup: A
//    stable IMP retains its declared UNINITIALIZED state. One input compares
//    against that same state;the other against DONE. Six typed waiters start
//    before a positive-time sample. Expected predicates use ordinary
//    relational operators on the actual named values,not hardcoded numeric
//    encodings. Pending false waiters are canceled after observation.
//    Expected: The selected named operator returns immediately exactly for the
//    selected true predicate;false predicates remain pending and the phase and
//    peer states remain unchanged.
// 2. 1800.2-2020 F.2.5.3 (UVM-PKG-WAIT-OP-NE-91) gives rule 2 above. Setup: A
//    stable IMP retains its declared UNINITIALIZED state. One input compares
//    against that same state;the other against DONE. Six typed waiters start
//    before a positive-time sample. Expected predicates use ordinary
//    relational operators on the actual named values,not hardcoded numeric
//    encodings. Pending false waiters are canceled after observation.
//    Expected: The selected named operator returns immediately exactly for the
//    selected true predicate;false predicates remain pending and the phase and
//    peer states remain unchanged.
// 3. 1800.2-2020 F.2.5.3 (UVM-PKG-WAIT-OP-LT-91) gives rule 3 above. Setup: A
//    stable IMP retains its declared UNINITIALIZED state. One input compares
//    against that same state;the other against DONE. Six typed waiters start
//    before a positive-time sample. Expected predicates use ordinary
//    relational operators on the actual named values,not hardcoded numeric
//    encodings. Pending false waiters are canceled after observation.
//    Expected: The selected named operator returns immediately exactly for the
//    selected true predicate;false predicates remain pending and the phase and
//    peer states remain unchanged.
// 4. 1800.2-2020 F.2.5.3 (UVM-PKG-WAIT-OP-LTE-91) gives rule 4 above. Setup: A
//    stable IMP retains its declared UNINITIALIZED state. One input compares
//    against that same state;the other against DONE. Six typed waiters start
//    before a positive-time sample. Expected predicates use ordinary
//    relational operators on the actual named values,not hardcoded numeric
//    encodings. Pending false waiters are canceled after observation.
//    Expected: The selected named operator returns immediately exactly for the
//    selected true predicate;false predicates remain pending and the phase and
//    peer states remain unchanged.
// 5. 1800.2-2020 F.2.5.3 (UVM-PKG-WAIT-OP-GT-91) gives rule 5 above. Setup: A
//    stable IMP retains its declared UNINITIALIZED state. One input compares
//    against that same state;the other against DONE. Six typed waiters start
//    before a positive-time sample. Expected predicates use ordinary
//    relational operators on the actual named values,not hardcoded numeric
//    encodings. Pending false waiters are canceled after observation.
//    Expected: The selected named operator returns immediately exactly for the
//    selected true predicate;false predicates remain pending and the phase and
//    peer states remain unchanged.
// 6. 1800.2-2020 F.2.5.3 (UVM-PKG-WAIT-OP-GTE-91) gives rule 6 above. Setup: A
//    stable IMP retains its declared UNINITIALIZED state. One input compares
//    against that same state;the other against DONE. Six typed waiters start
//    before a positive-time sample. Expected predicates use ordinary
//    relational operators on the actual named values,not hardcoded numeric
//    encodings. Pending false waiters are canceled after observation.
//    Expected: The selected named operator returns immediately exactly for the
//    selected true predicate;false predicates remain pending and the phase and
//    peer states remain unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Six typed operators are checked on a stable uninitialized IMP state against
// equal or different named thresholds. True predicates return
// immediately;false waits remain blocked until canceled. No numeric enum
// encoding,state-mask or complete live progression claim.
module test_pkg_wait_operators_0_91;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=0;
  localparam string CASE_NAME="pkg_wait_operators_0";
  `include "wait_fixture91.svh"
  initial begin #5000; $fatal(1,"typed role/event/topology91 watchdog"); end
endmodule
