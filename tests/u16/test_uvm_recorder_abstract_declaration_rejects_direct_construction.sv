/*
:name: test_uvm_recorder_abstract_declaration_rejects_direct_construction
:description: recorder rejects the selected illegal declaration
:tags: u16 uvm
:type: elaboration
:lrm: 1800.2-2020 16.4.1 1800-2023 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the virtual or incomplete recorder cannot be constructed
:expected_stderr_regex: (?i)^(?=.*test_uvm_recorder_abstract_declaration_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_recorder\b).*error
*/
module test_uvm_recorder_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_recorder illegal_value;
    illegal_value=new();
  end
endmodule
