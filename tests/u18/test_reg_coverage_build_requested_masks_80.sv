/*
:name: test_reg_coverage_build_requested_masks_80
:description: Protected register coverage selection returns included requested models across distinct masks
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.7.2 18.4.7.1 18.4.2.2 18.1.2.2 17.2.2.9 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers80/coverage80.svh
:expected_exit: 0
:expected_stdout: @test_reg_coverage_build_requested_masks_80.expected
*/
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_build_requested_masks_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_block80 owner=new("owner80");
    automatic coverage_reg80 r=new("reg80");
    owner.configure(); r.configure(owner);
    uvm_reg::include_coverage("owner80.reg80",UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS);
    $display("UT: coverage80 requested all %0d mixed %0d no %0d zero %0d field %0d repeat %0d",
      r.selected(UVM_CVR_ALL)==(UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS),
      r.selected(UVM_CVR_REG_BITS|UVM_CVR_ADDR_MAP)==UVM_CVR_REG_BITS,
      r.selected(UVM_CVR_ADDR_MAP)==UVM_NO_COVERAGE,
      r.selected(UVM_NO_COVERAGE)==UVM_NO_COVERAGE,
      r.selected(UVM_CVR_FIELD_VALS)==UVM_CVR_FIELD_VALS,
      r.selected(UVM_CVR_ALL)==(UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS));
    $finish;
  end
endmodule
