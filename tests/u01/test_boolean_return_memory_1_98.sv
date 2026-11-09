/*
:name: test_boolean_return_memory_1_98
:description: One-sided Boolean predicate descriptions imply the opposite return for valid nonmatching model states
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4.2 18.6.4.3 18.6.3.1 18.6.3.2 18.2.3.4 18.1.2.3 18.1.2.6 1800-2023 6.11 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers98/return_predicates98.svh
:expected_exit: 0
:expected_stdout: @test_boolean_return_memory_1_98.expected
*/
// What it checks:
// Selected memory membership predicates return true for actual membership and
// the inferred false for valid nonmember maps.
//
// Variant: Inputs 0 and 1 swap which of two independent objects is the
// selected one and which is the peer, and reverse their construction order.
//
// How the expected output follows from the standard:
// 1800.2-2020 1.4.2 (UVM-BOOLEAN-RETURNS-MEMORY-MAP-98) gives the rule above.
// Setup: Use separate original 32-location 8-bit memory models and two
// explicit valid maps. Observe initially absent, selected/peer maps,
// additional membership at a nonoverlapping offset and a post-lock repeat with
// reversed creation/selection histories. Expected: The raw predicate
// observations match literal 1/0 for the stated true condition and its valid
// opposite, preserving selected/peer independence across the declared
// histories.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_boolean_return_memory_1_98;
  import uvm_pkg::*;
  localparam int FAMILY98=2;
  localparam int VARIANT98=1;
  localparam string FAMILY_NAME98="memory";
  `include "return_predicates98.svh"
endmodule
