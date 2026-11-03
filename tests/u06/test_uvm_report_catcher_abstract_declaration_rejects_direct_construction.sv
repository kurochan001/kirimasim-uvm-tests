/*
:name: test_uvm_report_catcher_abstract_declaration_rejects_direct_construction
:description: abstract uvm_report_catcher cannot be directly constructed (IEEE 1800.2-2020 Section 6.6.1)
:tags: u06 uvm
:type: elaboration
:lrm: 1800.2-2020 6.6.1 6.6.2 1800-2023 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of a standard-declared virtual class is illegal
:expected_stderr_regex: (?i)^(?=.*test_uvm_report_catcher_abstract_declaration_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_report_catcher\b).*error
*/
// Use the declared constructor arguments and target the abstract class itself.
// The diagnostic must identify this fixture and its virtual/abstract base.
// Rejection is a compile-stage observation; no runtime seed or output exists.
module test_uvm_report_catcher_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_report_catcher illegal_handle;
    illegal_handle = new("illegal");
  end
endmodule
