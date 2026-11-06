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
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_implementation_version_parameter_assignment_83;
  import uvm_pkg::*;
  initial begin
    uvm_pkg::UVM_VERSION_STRING="illegal83";
  end
endmodule
