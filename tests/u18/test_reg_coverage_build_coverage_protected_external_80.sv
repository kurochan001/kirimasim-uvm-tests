/*
:name: test_reg_coverage_build_coverage_protected_external_80
:description: External module access to protected register build_coverage is illegal
:tags: u18 uvm
:type: elaboration
:lrm: 1800.2-2020 18.4.7.2 18.4.2.1 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers80/coverage80.svh
:should_fail_because: module scope cannot call protected build_coverage
:expected_stderr_regex: (?i)^(?=.*test_reg_coverage_build_coverage_protected_external_80.sv:[0-9]+:[0-9]+:)(?=.*\b(?:protected|private|inaccessible)\b)(?=.*\bbuild_coverage\b).*error
*/
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_build_coverage_protected_external_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_reg80 r=new("reg80");
    uvm_reg_cvr_t illegal_result;
    illegal_result=r.build_coverage(UVM_CVR_ALL);
    $finish;
  end
endmodule
