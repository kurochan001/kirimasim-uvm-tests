/*
:name: test_case_sensitive_sequence_1_101
:description: Selected UVM names differing only by case retain exact lookup and state under changed construction and lifecycle conditions
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4 14.1.2.7 14.1.2.8 14.1.2.9 14.2.3.1 14.1.2.12 14.1.2.13 14.1.2.14 5.3.4.1 5.3.4.2 5.3.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers101_sequence/sequence101.svh
:expected_exit: 0
:expected_stdout: @test_case_sensitive_sequence_1_101.expected
*/
// What it checks:
// Inactive sequence paths and root names preserve caller-supplied case through
// parent and name changes.
//
// Variant: Inputs 0 and 1 swap which of two sequence chains is reparented and
// renamed and which supplies the new parent and the renamed root.
//
// How the expected output follows from the standard:
// 1800.2-2020 1.4 (UVM-CASE-SENSITIVE-SEQUENCE-NAMES-101) gives the rule
// above. Setup: Create two case-only three-level sequence chains, reparent the
// selected tip, rename the current shared root and selected tip, then detach
// that tip. Expected: Paths are the current supplied names joined by dots;
// parent/root handles and root names follow the current chain while tip
// identities remain stable.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_case_sensitive_sequence_1_101;
  import uvm_pkg::*;
  localparam int VARIANT101=1;
  `include "sequence101.svh"
endmodule
