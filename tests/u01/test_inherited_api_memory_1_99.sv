/*
:name: test_inherited_api_memory_1_99
:description: Selected inherited APIs preserve documented name and identity semantics through original bridge and leaf types
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4.3 5.3.4.1 5.3.4.2 5.3.4.4 18.6.1 18.6.3.1 18.6.3.2 18.6.4.1 18.6.4.7 18.6.4.9 18.1.1 18.1.2.1 18.1.2.2 18.1.2.3 18.2.3.4 1800-2023 6.21 8.13 8.14 8.15 8.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers99/inherited_api99.svh
:expected_exit: 0
:expected_stdout: @test_inherited_api_memory_1_99.expected
*/
// What it checks:
// Configured memory bridge/leaf objects retain inherited simple-name and
// lifetime-ID semantics alongside their parent and declared shape.
//
// Variant: Inputs 0 and 1 swap which of two objects is the selected one and
// which is the peer, reverse their construction order, and rename them through
// opposite views: input 0 renames the selected object through its base view
// and the peer through its leaf class, input 1 the other way round.
//
// How the expected output follows from the standard:
// 1800.2-2020 1.4.3 (UVM-INHERITED-MEMORY-OBJECT-API-99) gives the rule above.
// Setup: Construct two original leaf instances through an original
// intermediate bridge over the selected UVM class, overriding only
// constructors. Reverse creation/selection, use object/bridge/leaf views, and
// change selected then peer then selected names through different static
// views. Hold both instances live; compare saved IDs and peer independence.
// Configure model-only receivers under one original block and a real address
// map; registers have one full-width field, and memories have 16 locations of
// 8 bits. Expected: Supplied simple names are visible from all selected views;
// IDs are stable across name changes and distinct for the two live objects.
// Parent handles and declared width/size remain as configured.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_inherited_api_memory_1_99;
  import uvm_pkg::*;
  localparam int FAMILY99=5;
  localparam int VARIANT99=1;
  localparam string FAMILY_NAME99="memory";
  `include "inherited_api99.svh"
endmodule
