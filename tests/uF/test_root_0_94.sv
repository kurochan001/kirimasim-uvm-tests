/*
:name: test_root_0_94
:description: Implicit root parents and live component/object views agree under a qualified reading of the printed root declaration
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7 F.7.1 F.7.2.2 13.1.2.1 13.1.3.1 13.1.3.4 1800-2023 6.21 8.20 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers94_root/root_fixture94.svh
:expected_exit: 0
:expected_stdout: @test_root_0_94.expected
*/
// What it checks:
// 1. Null-parent components become children of the implicit root, and nested
//    components retain their live ancestry through that root.
// 2. Under the surrounding root description, the root singleton has live
//    uvm_component and uvm_object base views.
//
// Variant: Input 0 creates the first top component before the second and puts
// the leaf under it; input 1 creates it after the second and puts the leaf
// under the second.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.7 (UVM-ROOT-NULL-PARENT-LIVE-HIERARCHY-94) gives rule 1
//    above. Setup: Construct an original top child before or after the first
//    public root get, add a distinct top branch and a nested leaf, retain the
//    root component view, then add another null-parent child. Expected: Both
//    top parents are the root, the leaf parent chain reaches it, and a
//    retained base view sees the later child without changing either original
//    branch.
// 2. 1800.2-2020 F.7.1 (UVM-ROOT-QUALIFIED-COMPONENT-BASE-94) gives rule 2
//    above. Setup: Obtain the public singleton without constructing or
//    extending it; upcast to component and object, downcast to root, and query
//    actual children through the retained component view. Expected: All
//    base/downcast views retain the singleton identity and expose the actual
//    initial and later-added root children.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_root_0_94;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=0;
  `include "root_fixture94.svh"
endmodule
