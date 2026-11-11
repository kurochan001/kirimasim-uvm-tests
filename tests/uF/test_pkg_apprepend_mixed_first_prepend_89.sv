/*
:name: test_pkg_apprepend_mixed_first_prepend_89
:description: pkg apprepend mixed first prepend observes independently derived enum effects and preserved controls
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.7 10.7.2.3.1 B.4.1 B.4.3 1800-2023 6.21 8.20 18.5
:uvm: 2020.3.1
:files: helpers89/apprepend_fixture89.svh
:incdirs: helpers89
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_apprepend_mixed_first_prepend_89.expected
*/
// What it checks:
// 1. UVM_APPEND places the new item at the back of the selected
//    order-dependent sequence.
// 2. UVM_PREPEND places the new item at the front of the selected
//    order-dependent sequence.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.2.7 (UVM-PKG-APPREPEND-APPEND-89) gives rule 1 above.
//    Setup: Two independent source inputs use the actual registered
//    enabled-callback dispatcher. Five typed insertions alternate
//    append/prepend from opposite first modes; each exact dispatch trace is
//    observed. An independent empty peer receives no instance callbacks.
//    Expected traces are independently constructed from the enum front/back
//    meaning before execution. Expected: Append adds the new callback after
//    the existing sequence;prepend adds it before that sequence,without
//    changing the empty peer or fixing numeric enum encodings.
// 2. 1800.2-2020 F.2.7 (UVM-PKG-APPREPEND-PREPEND-89) gives rule 2 above.
//    Setup: Two independent source inputs use the actual registered
//    enabled-callback dispatcher. Five typed insertions alternate
//    append/prepend from opposite first modes; each exact dispatch trace is
//    observed. An independent empty peer receives no instance callbacks.
//    Expected traces are independently constructed from the enum front/back
//    meaning before execution. Expected: Append adds the new callback after
//    the existing sequence;prepend adds it before that sequence,without
//    changing the empty peer or fixing numeric enum encodings.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_pkg_apprepend_mixed_first_prepend_89;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=1;
  localparam string CASE_NAME="pkg_apprepend_mixed_first_prepend";
  `include "apprepend_fixture89.svh"
  initial begin #5000; $fatal(1,"allocation or ordering89 watchdog"); end
endmodule
