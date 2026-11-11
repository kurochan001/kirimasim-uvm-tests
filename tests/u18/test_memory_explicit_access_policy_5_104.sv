/*
:name: test_memory_explicit_access_policy_5_104
:description: Explicit memory access reflects selected map restrictions or intrinsic ROM policy independently of parent default
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.6 18.6.4.5 18.6.4.2 18.6.3.1 18.6.3.2 18.2.3.4 18.1.2.3 18.1.2.4 18.1.2.5 18.1.2.6 1800-2023 6.21 8.13 8.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers104_access/access104.svh
:expected_exit: 0
:expected_stdout: @test_memory_explicit_access_policy_5_104.expected
*/
// What it checks:
// Memory get_access includes intrinsic memory access restrictions.
//
// Variant: Inputs 0, 2 and 4 use a 16-bit memory of 3 locations, inputs 1, 3
// and 5 a 40-bit memory of 5 locations. Inputs 2, 3 and 5 also add the memory
// to the second map; inputs 4 and 5 configure it as RO. The first map adds it
// with RW rights in input 4, RO in inputs 0, 2 and 5, and WO in inputs 1 and
// 3.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.6.4.6 (UVM-MEMORY-EFFECTIVE-ACCESS) gives the rule above.
// Setup: Map an intrinsic read-only memory through RW maps. Expected:
// Effective access remains RO even though map rights are RW.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_explicit_access_policy_5_104;
  import uvm_pkg::*;
  localparam int CASE104=5,WIDTH104=40,SIZE104=5;
  localparam bit SHARED104=1,ROM104=1;
  `include "access104.svh"
endmodule
