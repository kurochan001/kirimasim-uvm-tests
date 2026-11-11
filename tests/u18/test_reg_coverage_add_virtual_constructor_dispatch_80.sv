/*
:name: test_reg_coverage_add_virtual_constructor_dispatch_80
:description: An inherited caller dispatches the protected virtual add hook during derived construction
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
:expected_stdout: @test_reg_coverage_add_virtual_constructor_dispatch_80.expected
*/
// What it checks:
// The protected add_coverage hook dispatches virtually when an inherited
// caller invokes it during derived construction.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.7.3 (UVM-REG-COVERAGE-ADD-VIRTUAL-DISPATCH) gives the rule
// above. Setup: Original derived register constructors preserve a supplied
// base mask and call the actual protected add_coverage while their constructor
// is active. Cases include zero, overlapping/repeated additions, isolated
// peers, inherited virtual dispatch and explicit measurement-off then
// all-model selection. Expected: The override receives the selected model once
// and its super delegation preserves the base model and adds the requested
// model.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_add_virtual_constructor_dispatch_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_hook80 r=new("hook80");
    $display("UT: coverage80 virtual calls %0d argument %0d original %0d added %0d excluded %0d",
      r.calls==1,r.last_models==UVM_CVR_ADDR_MAP,r.has_coverage(UVM_CVR_REG_BITS),
      r.has_coverage(UVM_CVR_ADDR_MAP),!r.has_coverage(UVM_CVR_FIELD_VALS));
    $finish;
  end
endmodule
