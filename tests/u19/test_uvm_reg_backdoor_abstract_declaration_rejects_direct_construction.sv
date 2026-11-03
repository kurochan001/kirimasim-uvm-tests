/*
:name: test_uvm_reg_backdoor_abstract_declaration_rejects_direct_construction
:description: abstract uvm_reg_backdoor cannot be directly constructed (IEEE 1800.2-2020 Section 19.5.1)
:tags: u19 uvm
:type: elaboration
:lrm: 1800.2-2020 19.5.1 19.5.2.1 1800-2023 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of a standard-declared virtual class is illegal
:expected_stderr_regex: (?i)^(?=.*test_uvm_reg_backdoor_abstract_declaration_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_reg_backdoor\b).*error
*/
// Use the declared constructor arguments and target the abstract class itself.
// The diagnostic must identify this fixture and its virtual/abstract base.
// Rejection is a compile-stage observation; no runtime seed or output exists.
module test_uvm_reg_backdoor_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_reg_backdoor illegal_handle;
    illegal_handle = new("illegal");
  end
endmodule
