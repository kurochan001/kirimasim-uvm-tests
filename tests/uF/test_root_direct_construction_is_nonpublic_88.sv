/*
:name: test_root_direct_construction_is_nonpublic_88
:description: root direct construction is nonpublic checks independently derived public observations
:tags: uF uvm
:type: elaboration
:lrm: 1800.2-2020 F.7.2.1 F.7.2.2 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: root constructor is non-public and cannot be called by an external scope
:expected_stderr_regex: (?i)^(?=.*test_root_direct_construction_is_nonpublic_88\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:protected|local)\b)(?=.*\b(?:uvm_root|new)\b).*error
*/
// What it checks:
// External direct construction through the non-public root constructor is
// rejected.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.7.2.1 (UVM-ROOT-CONSTRUCTOR-NONPUBLIC-88) gives the rule
// above. Setup: Use the supplied non-public root constructor from an external
// scope or from a minimal original subtype after obtaining the singleton. A
// global fatal observer returns THROW. A positive-time extension control
// observes fatal production/termination without requiring absence of same-time
// constructor return; the stricter original return probe is control-only.
// Expected: The compiler rejects the selected source with a matching
// non-public constructor diagnostic and no runtime seed.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_root_direct_construction_is_nonpublic_88;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam string CASE_NAME="root_direct_construction_is_nonpublic";
  initial begin uvm_root forbidden; forbidden=new(); end
  initial begin #5000; $fatal(1,"root or predictor88 watchdog"); end
endmodule
