/*
:name: test_boolean_return_virtual_0_98
:description: One-sided Boolean predicate descriptions imply the opposite return for valid nonmatching model states
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4.2 18.9.1.2.4 18.9.1.1.1 18.9.1.1.2 18.9.1.1.3 18.6.3.1 18.6.3.2 18.2.3.4 18.1.2.3 18.1.2.6 1800-2023 6.11 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers98/return_predicates98.svh
:expected_exit: 0
:expected_stdout: @test_boolean_return_virtual_0_98.expected
*/
// What it checks:
// Selected implemented virtual-register arrays report true only for their
// backing memory maps and false for other valid maps.
//
// Variant: Inputs 0 and 1 swap which of two independent objects is the
// selected one and which is the peer, and reverse their construction order.
//
// How the expected output follows from the standard:
// 1800.2-2020 1.4.2 (UVM-BOOLEAN-RETURNS-VIRTUAL-MAP-98) gives the rule above.
// Setup: Construct two original 16-bit arrays of 3 elements backed by separate
// 32-location 8-bit memories, offset 5 and stride 3. Use static configure in
// one input and explicit successful dynamic implement in the other. Query no
// null/unimplemented handle; change actual backing-memory map associations
// before the post-lock repeat. Expected: The raw predicate observations match
// literal 1/0 for the stated true condition and its valid opposite, preserving
// selected/peer independence across the declared histories.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_boolean_return_virtual_0_98;
  import uvm_pkg::*;
  localparam int FAMILY98=3;
  localparam int VARIANT98=0;
  localparam string FAMILY_NAME98="virtual";
  `include "return_predicates98.svh"
endmodule
