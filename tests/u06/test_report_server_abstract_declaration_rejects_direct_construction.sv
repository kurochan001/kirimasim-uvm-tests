/*
:name: test_report_server_abstract_declaration_rejects_direct_construction
:description: virtual report server rejects direct construction (6.5.1.1)
:tags: u06 uvm
:type: elaboration
:lrm: 1800.2-2020 6.5.1.1 6.5.1 6.5.1.2.1 1800-2023 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a virtual report server cannot be directly constructed
:expected_stderr_regex: (?i)^(?=.*test_report_server_abstract_declaration_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_report_server\b).*error
*/
// What it checks:
// The declared virtual report server cannot be directly constructed.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.5.1.1 (UVM-REPORT-AUDIT-BASE-ABSTRACT-DECLARATION) gives the
// rule above. Setup: Use the selected original reporting fixtures and explicit
// object, severity, ID and action configuration described by their observation
// anchors. Expected: Compilation rejects direct new with the targeted
// virtual/abstract class error; no runtime seed executes.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_report_server_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_report_server illegal_value;
    illegal_value = new();
  end
endmodule
