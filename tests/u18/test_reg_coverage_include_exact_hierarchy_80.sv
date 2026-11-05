/*
:name: test_reg_coverage_include_exact_hierarchy_80
:description: Exact full-name inclusion separates equal register leaf names in different branches
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.7.1 18.4.7.2 18.4.2.2 18.4.3.2 18.1.2.2 17.2.2.9 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers80/coverage80.svh
:expected_exit: 0
:expected_stdout: @test_reg_coverage_include_exact_hierarchy_80.expected
*/
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_include_exact_hierarchy_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_block80 root=new("root80");
    automatic coverage_block80 left=new("left80");
    automatic coverage_block80 right=new("right80");
    automatic coverage_reg80 a=new("reg80");
    automatic coverage_reg80 b=new("reg80");
    root.configure(); left.configure(root); right.configure(root);
    a.configure(left); b.configure(right);
    uvm_reg::include_coverage("root80.left80.reg80",UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS);
    uvm_reg::include_coverage("root80.right80.reg80",UVM_CVR_ADDR_MAP);
    $display("UT: coverage80 exact names %0d left %0d right %0d repeat %0d",
      a.get_full_name()=="root80.left80.reg80" && b.get_full_name()=="root80.right80.reg80",
      a.selected(UVM_CVR_ALL)==(UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS),
      b.selected(UVM_CVR_ALL)==UVM_CVR_ADDR_MAP,
      a.selected(UVM_CVR_ALL)==(UVM_CVR_REG_BITS|UVM_CVR_FIELD_VALS));
    $finish;
  end
endmodule
