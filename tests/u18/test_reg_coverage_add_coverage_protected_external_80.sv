/*
:name: test_reg_coverage_add_coverage_protected_external_80
:description: External module access to protected register add_coverage is illegal
:tags: u18 uvm
:type: elaboration
:lrm: 1800.2-2020 18.4.7.3 18.4.2.1 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers80/coverage80.svh
:should_fail_because: module scope cannot call protected add_coverage
:expected_stderr_regex: (?i)^(?=.*test_reg_coverage_add_coverage_protected_external_80.sv:[0-9]+:[0-9]+:)(?=.*\b(?:protected|private|inaccessible)\b)(?=.*\badd_coverage\b).*error
*/
// What it checks:
// The protected add_coverage method cannot be called from external module
// scope.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.7.3 (UVM-REG-COVERAGE-ADD-PROTECTED-DECLARATION) gives the
// rule above. Setup: Original derived register constructors preserve a
// supplied base mask and call the actual protected add_coverage while their
// constructor is active. Cases include zero, overlapping/repeated additions,
// isolated peers, inherited virtual dispatch and explicit measurement-off then
// all-model selection. Expected: The compiler rejects the external call with
// the selected protected-access diagnostic; legitimate constructor additions
// are a separate control.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_add_coverage_protected_external_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_reg80 r=new("reg80");
    r.add_coverage(UVM_CVR_REG_BITS);
    $finish;
  end
endmodule
