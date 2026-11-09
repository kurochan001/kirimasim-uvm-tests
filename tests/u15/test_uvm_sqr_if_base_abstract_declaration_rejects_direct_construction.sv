/*
:name: test_uvm_sqr_if_base_abstract_declaration_rejects_direct_construction
:description: uvm sqr if base abstract declaration rejects direct construction
:tags: u15 uvm
:type: elaboration
:lrm: 1800.2-2020 15.2.1.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of the declared virtual class is illegal
:expected_stderr_regex: (?i)(?=.*(?:virtual|abstract))(?=.*uvm_sqr_if_base).*
*/
// What it checks:
// The declared virtual uvm_sqr_if_base rejects direct construction.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.2.1.1 (UVM-SQR-AUDIT-UVM-SQR-IF-BASE-ABSTRACT) gives the rule
// above. Setup: Use the selected original fixture, declared type arguments,
// public endpoint/base views and linked stage observations. Requests satisfy
// the grant precondition before send_request and response IDs are copied from
// the actual request. Expected: The declared virtual uvm_sqr_if_base rejects
// direct construction.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_uvm_sqr_if_base_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    automatic uvm_sqr_if_base#() illegal=new();
  end
endmodule
