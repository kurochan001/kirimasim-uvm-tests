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
// What it checks:
// The register coverage builder returns the requested models selected by the
// applicable inclusion specification.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.7.2 (UVM-REG-COVERAGE-BUILD-INCLUDED-REQUESTED-MODELS)
// gives the rule above. Setup: Original configured block/register/memory
// objects use full hierarchical names, exact or simple glob scopes, explicit
// disjoint peer inclusions and legal combined model identifiers. Protected
// builders are called through legal derived wrappers. The requested-model
// selection reads18.4.7.2 together with18.4.7.1 and the explicit analogous
// block contract18.1.4.1. Expected: All, intersecting, excluded-only, zero and
// individual requests return the corresponding included requested masks on
// repeated calls.
// It also supports, as a control, the setup or conditions of
// UVM-REG-COVERAGE-BUILD-PROTECTED-DECLARATION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
