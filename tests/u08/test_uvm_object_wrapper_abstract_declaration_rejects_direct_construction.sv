/*
:name: test_uvm_object_wrapper_abstract_declaration_rejects_direct_construction
:description: abstract uvm_object_wrapper cannot be directly constructed (IEEE 1800.2-2020 Section 8.3.2.1)
:tags: u08 uvm
:type: elaboration
:lrm: 1800.2-2020 8.3.2.1 8.3.2 1800-2023 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of a standard-declared virtual class is illegal
:expected_stderr_regex: (?i)^(?=.*test_uvm_object_wrapper_abstract_declaration_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_object_wrapper\b).*error
*/
// What it checks:
// The standard-declared virtual uvm_object_wrapper cannot be directly
// instantiated.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.3.2.1 (UVM-ABSTRACT-OBJECT-WRAPPER-DIRECT-CONSTRUCTION) gives
// the rule above. Setup: Use the declared constructor arguments and selected
// class specialization in a direct new expression, without an original
// concrete subtype. Expected: Compilation rejects the fixture with an error
// identifying its virtual/abstract class. There is no runtime seed execution.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use the declared constructor arguments and target the abstract class itself.
// The diagnostic must identify this fixture and its virtual/abstract base.
// Rejection is a compile-stage observation; no runtime seed or output exists.
module test_uvm_object_wrapper_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_object_wrapper illegal_handle;
    illegal_handle = new();
  end
endmodule
