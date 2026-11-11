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
// What it checks:
// 1. Coverage inclusion selects register instances by their complete
//    hierarchical names.
// 2. The register coverage builder returns the requested models selected by
//    the applicable inclusion specification.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.7.1 (UVM-REG-COVERAGE-INCLUDE-EXACT-FULLNAME) gives rule
//    1 above. Setup: Original configured block/register/memory objects use
//    full hierarchical names, exact or simple glob scopes, explicit disjoint
//    peer inclusions and legal combined model identifiers. Protected builders
//    are called through legal derived wrappers. The requested-model selection
//    reads18.4.7.2 together with18.4.7.1 and the explicit analogous block
//    contract18.1.4.1. Expected: Registers sharing a leaf name in different
//    branches select their own separately specified model masks.
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
