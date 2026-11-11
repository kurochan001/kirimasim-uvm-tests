/*
:name: test_size_version_implementation_version_parameter_assignment_83
:description: The implementation version parameter rejects a procedural assignment to its constant
:tags: uB uvm
:type: elaboration
:lrm: 1800.2-2020 B.7.2  1800-2023 6.21 6.20 6.16 7.4 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: A package value parameter cannot be assigned procedurally
:expected_stderr_regex: (?i)^(?=.*test_size_version_implementation_version_parameter_assignment_83\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:const|constant|parameter)\b).*error
*/
// What it checks:
// The implementation version is a value parameter and cannot be assigned
// procedurally.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.7.2 (UVM-SIZE-VERSION-IMPLEMENTATION-PARAMETER-IMMUTABILITY)
// gives the rule above. Setup: Unmodified public UVM types/macros and default
// packer implementation. Flag overrides use the actual reserved-count
// parameter plus17 or129,without fixing its implementation-dependent value.
// Capacity inputs explicitly flush and retain32768 bits via independent
// original8/64-bit payload patterns. Version inputs use public
// package/preprocessor access;the illegal parameter assignment has no runtime.
// Expected: A procedural assignment rejects with the declared source/constant
// diagnostic and executes no runtime seed.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_implementation_version_parameter_assignment_83;
  import uvm_pkg::*;
  initial begin
    uvm_pkg::UVM_VERSION_STRING="illegal83";
  end
endmodule
