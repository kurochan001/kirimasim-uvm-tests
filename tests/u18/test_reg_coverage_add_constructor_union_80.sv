/*
:name: test_reg_coverage_add_constructor_union_80
:description: Derived constructor additions preserve original models and overlapping additions
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
:expected_stdout: @test_reg_coverage_add_constructor_union_80.expected
*/
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_add_constructor_union_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_added80 r=new("reg80",UVM_CVR_REG_BITS,
      UVM_CVR_ADDR_MAP,UVM_CVR_ADDR_MAP|UVM_CVR_FIELD_VALS);
    automatic coverage_reg80 peer=new("peer80",UVM_CVR_REG_BITS);
    $display("UT: coverage80 add original %0d first %0d overlap %0d union %0d peer %0d",
      r.has_coverage(UVM_CVR_REG_BITS),r.has_coverage(UVM_CVR_ADDR_MAP),
      r.has_coverage(UVM_CVR_FIELD_VALS),
      r.has_coverage(UVM_CVR_REG_BITS|UVM_CVR_ADDR_MAP|UVM_CVR_FIELD_VALS),
      peer.has_coverage(UVM_CVR_REG_BITS) && !peer.has_coverage(UVM_CVR_ADDR_MAP));
    $finish;
  end
endmodule
