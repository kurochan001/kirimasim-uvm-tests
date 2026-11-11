/*
:name: test_reg_coverage_include_block_reg_memory_80
:description: One hierarchical include specification selects block register and memory construction masks
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.7.1 18.4.7.2 18.1.4.1 18.6.8.1 18.4.2.2 18.6.3.2 18.1.2.2 17.2.2.9 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers80/coverage80.svh
:expected_exit: 0
:expected_stdout: @test_reg_coverage_include_block_reg_memory_80.expected
*/
// What it checks:
// 1. Register coverage inclusion applies to matching block, register and
//    memory abstraction instances.
// 2. The register coverage builder returns the requested models selected by
//    the applicable inclusion specification.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.7.1 (UVM-REG-COVERAGE-INCLUDE-BLOCK-REGISTER-MEMORY)
//    gives rule 1 above. Setup: Original configured block/register/memory
//    objects use full hierarchical names, exact or simple glob scopes,
//    explicit disjoint peer inclusions and legal combined model identifiers.
//    Protected builders are called through legal derived wrappers. The
//    requested-model selection reads18.4.7.2 together with18.4.7.1 and the
//    explicit analogous block contract18.1.4.1. Expected: One supplied
//    hierarchical selection produces the same combined requested models in the
//    three abstraction kinds while an outside peer remains excluded.
// 2. 1800.2-2020 18.4.7.2 (UVM-REG-COVERAGE-BUILD-INCLUDED-REQUESTED-MODELS)
//    gives rule 2 above. Setup: Original configured block/register/memory
//    objects use full hierarchical names, exact or simple glob scopes,
//    explicit disjoint peer inclusions and legal combined model identifiers.
//    Protected builders are called through legal derived wrappers. The
//    requested-model selection reads18.4.7.2 together with18.4.7.1 and the
//    explicit analogous block contract18.1.4.1. Expected: All, intersecting,
//    excluded-only, zero and individual requests return the corresponding
//    included requested masks on repeated calls.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Coverage metadata or observer dispatch only; no bin, covergroup or HDL claim.
module test_reg_coverage_include_block_reg_memory_80;
  import uvm_pkg::*;
  `include "coverage80.svh"
  initial begin
    automatic coverage_block80 root=new("root80");
    automatic coverage_block80 bank=new("bank80");
    automatic coverage_block80 outside=new("outside80");
    automatic coverage_reg80 r=new("reg80");
    automatic coverage_mem80 m=new("mem80");
    automatic coverage_reg80 peer=new("reg80");
    automatic coverage_token80 accessor=new();
    automatic uvm_reg_cvr_t models=UVM_CVR_REG_BITS|UVM_CVR_ADDR_MAP;
    root.configure(); bank.configure(root); outside.configure(root);
    r.configure(bank); m.configure(bank); peer.configure(outside);
    uvm_reg::include_coverage("root80.bank80*",models,accessor);
    uvm_reg::include_coverage("root80.outside80.reg80",UVM_NO_COVERAGE);
    $display("UT: coverage80 kinds block %0d register %0d memory %0d peer %0d",
      bank.selected(UVM_CVR_ALL)==models, r.selected(UVM_CVR_ALL)==models,
      m.selected(UVM_CVR_ALL)==models,peer.selected(UVM_CVR_ALL)==UVM_NO_COVERAGE);
    $finish;
  end
endmodule
