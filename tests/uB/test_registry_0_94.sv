/*
:name: test_registry_0_94
:description: Low-level registration macros preserve custom lookup strings and the selected concrete class without utility macros
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.1.4 B.2.1.5 8.3.1.2.1 8.3.1.5 8.3.1.7.3 5.3.3.1 1800-2023 6.21 8.20 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers94_registry/registry_fixture94.svh
:expected_exit: 0
:expected_stdout: @test_registry_0_94.expected
*/
// What it checks:
// The low-level object registration macro associates its T class with the
// supplied lookup string S for factory creation.
//
// Variant: Inputs 0 and 1 create the two witnesses, and make the two creations
// by name, in opposite orders.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.2.1.4 (UVM-LOWLEVEL-OBJECT-REGISTRY-LOOKUP-94) gives the rule
// above. Setup: Use two concrete original classes with lookup strings
// different from their class names and only low-level registration macros.
// Construct witnesses, then create by each custom alias and repeat one alias
// under opposite ordering histories; components receive explicit parents.
// Expected: Each alias is registered and selects its actual concrete class,
// constructor marker and requested name; repeated results are fresh, with the
// selected component parent or independent object state.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_registry_0_94;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=0;
  localparam bit COMPONENT94=0;
  `include "registry_fixture94.svh"
endmodule
