/*
:name: test_uvm_policy_abstract_declaration_rejects_direct_construction
:description: virtual uvm_policy rejects direct construction (16.1.1)
:tags: u16 uvm
:type: elaboration
:lrm: 1800.2-2020 16.1.1 1800-2023 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the virtual base cannot be directly constructed
:expected_stderr_regex: (?i)^(?=.*test_uvm_policy_abstract_declaration_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_policy\b).*error
*/
module test_uvm_policy_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_policy illegal_value;
    illegal_value=new();
  end
endmodule
