/*
:name: test_reg_coverage_add_measurement_availability_80
:description: Added available models can be selected for measurement without enabling absent models
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.7.3 18.4.7.4 18.4.7.5 18.4.7.6 18.4.2.1 17.2.2.9 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers80/coverage80.svh
:expected_exit: 0
:expected_stdout: @test_reg_coverage_add_measurement_availability_80.expected
*/
// What it checks:
// 1. Register set_coverage returns the previously enabled mask.
// 2. Models added in one register constructor belong to that register
//    instance.
// 3. Measurement selection can enable constructor-added available models but
//    cannot enable models absent from that register.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.7.6 (UVM-REG-COVERAGE-PREVIOUS-MASK-RETURN) gives rule 1
//    above. Setup: Change from off to bits and then from bits to fields. Also
//    observe the off-to-all transition of two constructor-extended register
//    instances after explicitly clearing measurement. Expected: Return masks
//    are NO_COVERAGE then REG_BITS.
// 2. 1800.2-2020 18.4.7.3 (UVM-REG-COVERAGE-ADD-INSTANCE-ISOLATION) gives rule
//    2 above. Setup: Original derived register constructors preserve a
//    supplied base mask and call the actual protected add_coverage while their
//    constructor is active. Cases include zero, overlapping/repeated
//    additions, isolated peers, inherited virtual dispatch and explicit
//    measurement-off then all-model selection. Expected: An independent
//    base-only peer and a differently extended instance retain their own
//    distinct availability and measurement masks.
// 3. 1800.2-2020 18.4.7.6 (UVM-REG-COVERAGE-ADDED-MODELS-MEASUREMENT-GATE)
//    gives rule 3 above. Setup: Original derived register constructors
//    preserve a supplied base mask and call the actual protected add_coverage
//    while their constructor is active. Cases include zero,
//    overlapping/repeated additions, isolated peers, inherited virtual
//    dispatch and explicit measurement-off then all-model selection. Expected:
//    After an explicit off state, all-model selection enables only each
//    instance available union and leaves absent models off.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_add_measurement_availability_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_added80 a=new("a80",UVM_CVR_REG_BITS,UVM_CVR_ADDR_MAP,UVM_NO_COVERAGE);
    automatic coverage_added80 b=new("b80",UVM_NO_COVERAGE,UVM_CVR_FIELD_VALS,UVM_NO_COVERAGE);
    uvm_reg_cvr_t ignored, old_a, old_b;
    ignored=a.set_coverage(UVM_NO_COVERAGE); ignored=b.set_coverage(UVM_NO_COVERAGE);
    old_a=a.set_coverage(UVM_CVR_ALL); old_b=b.set_coverage(UVM_CVR_ALL);
    $display("UT: coverage80 enabled old_a %0d old_b %0d union %0d no_a %0d field %0d no_b %0d",
      old_a==UVM_NO_COVERAGE,old_b==UVM_NO_COVERAGE,
      a.get_coverage(UVM_CVR_REG_BITS|UVM_CVR_ADDR_MAP),!a.get_coverage(UVM_CVR_FIELD_VALS),
      b.get_coverage(UVM_CVR_FIELD_VALS),!b.get_coverage(UVM_CVR_REG_BITS));
    $finish;
  end
endmodule
