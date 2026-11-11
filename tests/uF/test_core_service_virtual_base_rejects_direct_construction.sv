/*
:name: test_core_service_virtual_base_rejects_direct_construction
:description: The virtual core-service base cannot be constructed directly
:tags: uF uvm
:type: elaboration
:lrm: 1800.2-2020 F.4.1.1 1800-2023 6.21 8.20 8.21 13.5.2 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the standard core-service base is virtual
:expected_stderr_regex: (?i)^(?=.*test_core_service_virtual_base_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\buvm_coreservice_t\b).*error
*/
// What it checks:
// The virtual core-service base cannot be constructed directly.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.4.1.1 (UVM-CORE-DECL-AUDIT-BASE-VIRTUAL) gives the rule above.
// Setup: Attempt direct new on an unextended uvm_coreservice_t variable.
// Expected: The compiler rejects this input and identifies the virtual
// core-service type.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_core_service_virtual_base_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_coreservice_t illegal_service;
    illegal_service=new();
  end
endmodule
