/*
:name: test_reg_coverage_add_zero_and_repeated_80
:description: Zero and repeated constructor additions retain the specified availability sets
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.7.3 18.4.7.4 18.4.2.1 17.2.2.9 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers80/coverage80.svh
:expected_exit: 0
:expected_stdout: @test_reg_coverage_add_zero_and_repeated_80.expected
*/
// What it checks:
// Zero or repeated coverage additions preserve the set of available register
// models.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.7.3 (UVM-REG-COVERAGE-ADD-ZERO-REPETITION) gives the rule
// above. Setup: Original derived register constructors preserve a supplied
// base mask and call the actual protected add_coverage while their constructor
// is active. Cases include zero, overlapping/repeated additions, isolated
// peers, inherited virtual dispatch and explicit measurement-off then
// all-model selection. Expected: Zero additions leave an empty set empty or a
// base model present; repeated field additions do not make other models
// available.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_add_zero_and_repeated_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_added80 empty_reg=new("empty80",UVM_NO_COVERAGE,
      UVM_NO_COVERAGE,UVM_NO_COVERAGE);
    automatic coverage_added80 bits=new("bits80",UVM_CVR_REG_BITS,
      UVM_NO_COVERAGE,UVM_CVR_REG_BITS);
    automatic coverage_added80 field_only=new("field80",UVM_NO_COVERAGE,
      UVM_CVR_FIELD_VALS,UVM_CVR_FIELD_VALS);
    $display("UT: coverage80 zero empty %0d retained %0d repeated %0d excluded %0d",
      !empty_reg.has_coverage(UVM_CVR_REG_BITS) &&
      !empty_reg.has_coverage(UVM_CVR_ADDR_MAP) &&
      !empty_reg.has_coverage(UVM_CVR_FIELD_VALS),
      bits.has_coverage(UVM_CVR_REG_BITS) && !bits.has_coverage(UVM_CVR_ADDR_MAP),
      field_only.has_coverage(UVM_CVR_FIELD_VALS),
      !field_only.has_coverage(UVM_CVR_REG_BITS) && !field_only.has_coverage(UVM_CVR_ADDR_MAP));
    $finish;
  end
endmodule
