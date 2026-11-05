/*
:name: test_reg_coverage_include_glob_siblings_80
:description: A simple scope pattern includes matching siblings and leaves explicitly excluded peers out
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.7.1 18.4.7.2 C.2.4 18.4.2.2 18.1.2.2 17.2.2.9 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers80/coverage80.svh
:expected_exit: 0
:expected_stdout: @test_reg_coverage_include_glob_siblings_80.expected
*/
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_include_glob_siblings_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_block80 root=new("root80");
    automatic coverage_block80 bank=new("bank80");
    automatic coverage_block80 other=new("other80");
    automatic coverage_reg80 a=new("rleft80");
    automatic coverage_reg80 b=new("rright80");
    automatic coverage_reg80 excluded=new("keep80");
    automatic coverage_reg80 peer=new("rleft80");
    root.configure(); bank.configure(root); other.configure(root);
    a.configure(bank); b.configure(bank); excluded.configure(bank); peer.configure(other);
    uvm_reg::include_coverage("root80.bank80.r*",UVM_CVR_FIELD_VALS);
    uvm_reg::include_coverage("root80.bank80.keep80",UVM_NO_COVERAGE);
    uvm_reg::include_coverage("root80.other80.rleft80",UVM_NO_COVERAGE);
    $display("UT: coverage80 glob first %0d second %0d excluded %0d branch %0d",
      a.selected(UVM_CVR_ALL)==UVM_CVR_FIELD_VALS,
      b.selected(UVM_CVR_ALL)==UVM_CVR_FIELD_VALS,
      excluded.selected(UVM_CVR_ALL)==UVM_NO_COVERAGE,
      peer.selected(UVM_CVR_ALL)==UVM_NO_COVERAGE);
    $finish;
  end
endmodule
