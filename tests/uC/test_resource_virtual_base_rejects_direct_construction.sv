/*
:name: test_resource_virtual_base_rejects_direct_construction
:description: Direct construction of the standard virtual resource base is illegal
:tags: uC uvm
:type: elaboration
:lrm: 1800.2-2020 C.2.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of the virtual resource base is illegal
:expected_stderr_regex: (?i)^(?=.*test_resource_virtual_base_rejects_direct_construction.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_resource_base\b).*error
*/
// What it checks:
// Direct construction of virtual uvm_resource_base is illegal.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.2.3.1 (UVM-RESOURCE-AUDIT-VIRTUAL-BASE) gives the rule above.
// Setup: A minimal illegal fixture isolates the named constructor, pure hook
// or typed read/write context. Expected: The compiler rejects the named
// declaration/type at the fixture location using the declared semantic
// diagnostic predicate.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_resource_virtual_base_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_resource_base illegal_resource;
    illegal_resource=new();
    $finish;
  end
endmodule
