/*
:name: test_phase_parent_queries_retain_each_explicit_hierarchy_edge
:description: phase parent queries retain each explicit hierarchy edge (IEEE 1800.2-2020 Section 9.3.1.6.2)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.6.2 9.3.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_parent_queries_retain_each_explicit_hierarchy_edge.expected
*/
// What it checks:
// Phase parent queries expose each immediate hierarchy edge.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.3.1.6.2 (UVM-PHASE-PARENT-HIERARCHY-EDGES) gives the rule
// above. Setup: Create a domain, outer/inner schedules, a leaf and an orphan.
// Expected: The three supplied parent handles match exactly and both roots
// have null parents.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Inspect local phase metadata and graphs without executing phase callbacks.
// Do not interpret get_schedule return typing or the get_imp NODE/IMP wording.
module test_phase_parent_queries_retain_each_explicit_hierarchy_edge;
  import uvm_pkg::*;

  initial begin
    automatic uvm_domain domain = new("alpha");
    automatic uvm_phase outer = new("outer", UVM_PHASE_SCHEDULE, domain);
    automatic uvm_phase inner = new("inner", UVM_PHASE_SCHEDULE, outer);
    automatic uvm_phase leaf = new("leaf", UVM_PHASE_NODE, inner);
    automatic uvm_phase orphan = new("orphan", UVM_PHASE_NODE);

    $display("UT: parents leaf %0d inner %0d outer %0d", leaf.get_parent() == inner,
    inner.get_parent() == outer, outer.get_parent() == domain);
    $display("UT: roots domain %0d orphan %0d", domain.get_parent() == null,
    orphan.get_parent() == null);
    $finish;
  end

endmodule
