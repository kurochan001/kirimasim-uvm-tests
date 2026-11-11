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
// What it checks:
// Direct construction of the abstract recorder is rejected.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.4.1 (UVM-POLICY-AUDIT-RECORDER-ILLEGAL-ABSTRACT) gives the
// rule above. Setup: Use the selected original fixtures, explicit arguments
// and stage observations in the linked anchors; each fresh policy and peer is
// independently constructed. Expected: Compile rejects the targeted abstract
// construction or isolated missing hook with the declared diagnostic; no
// runtime seeds execute.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_uvm_recorder_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_recorder illegal_value;
    illegal_value=new();
  end
endmodule
