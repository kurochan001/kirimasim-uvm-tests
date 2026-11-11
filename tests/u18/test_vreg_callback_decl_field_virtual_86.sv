/*
:name: test_vreg_callback_decl_field_virtual_86
:description: The listed virtual field callback facade rejects direct construction
:tags: u18 uvm
:type: elaboration
:lrm: 1800.2-2020 18.10.6.1 1800-2023 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of the standard-declared virtual callback class is illegal
:expected_stderr_regex: (?i)^(?=.*test_vreg_callback_decl_field_virtual_86\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_vreg_field_cbs\b).*error
*/
// What it checks:
// The listed virtual field-callback facade cannot be constructed directly.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.10.6.1 (UVM-VREG-CALLBACK-FIELD-FACADE-VIRTUAL-86) gives the
// rule above. Setup: Use the exact listed facade type or minimal original
// concrete subtype, without extra method bodies. The register facade is
// printed class; the field facade is printed virtual class. Static widening
// verifies callback-base compatibility. Direct virtual construction has only a
// compile-diagnostic oracle and no runtime seed. Expected: The listed virtual
// field-callback facade cannot be constructed directly.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_vreg_callback_decl_field_virtual_86;
  import uvm_pkg::*;
  initial begin
    uvm_vreg_field_cbs illegal_handle;
    illegal_handle=new();
  end
endmodule
