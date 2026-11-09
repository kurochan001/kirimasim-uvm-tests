/*
:name: test_case_sensitive_component_1_101
:description: Selected UVM names differing only by case retain exact lookup and state under changed construction and lifecycle conditions
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4 13.1.2.1 13.1.3.3 13.1.3.4 13.1.3.5 13.1.3.6 13.1.3.7 1.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers101_component/component101.svh
:expected_exit: 0
:expected_stdout: @test_case_sensitive_component_1_101.expected
*/
// What it checks:
// 1. Case-only component names identify distinct immediate children and exact
//    hierarchical lookup paths.
// 2. Child enumeration appends exactly the immediate case-distinct children
//    without imposing an unspecified traversal order.
//
// Variant: Inputs 0 and 1 create the objects whose names differ only by case
// in opposite orders.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 1.4 (UVM-CASE-SENSITIVE-COMPONENT-NAMES-101) gives rule 1
//    above. Setup: Construct route101/Route101 branches with leaf101/Leaf101
//    descendants, query a missing uppercase branch, then add ROUTE101 and
//    repeat the queries. Expected: Exact names select their own handles; an
//    unmatched spelling stays absent until explicitly added and cross-case
//    paths do not resolve.
// 2. 1800.2-2020 13.1.3.3 (UVM-COMPONENT-CASE-ENUMERATION-MULTIPLICITY-101)
//    gives rule 2 above. Setup: Use a caller prefix containing a descendant,
//    reverse construction and append a third case-only child after the first
//    query; iterate with a finite guard. Expected: The prefix is retained;
//    each immediate child appears once, descendants are excluded from the
//    appended suffix and the cursor is retained at exhaustion.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_case_sensitive_component_1_101;
  import uvm_pkg::*;
  localparam int VARIANT101=1;
  `include "component101.svh"
endmodule
