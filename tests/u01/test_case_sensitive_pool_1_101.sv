/*
:name: test_case_sensitive_pool_1_101
:description: Selected UVM names differing only by case retain exact lookup and state under changed construction and lifecycle conditions
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4 11.2.1 11.2.2.1 11.2.2.4 11.2.2.5 11.2.2.6 11.2.2.7 11.2.2.8 11.2.2.9 11.2.2.11 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers101_pool/pool101.svh
:expected_exit: 0
:expected_stdout: @test_case_sensitive_pool_1_101.expected
*/
// What it checks:
// String-key pool operations keep case-only keys and their stored values
// independent through delete, reinsert and overwrite.
//
// Variant: Input 0 deletes and re-adds the first of the two case-only keys and
// then overwrites the second; input 1 does the same with the two keys swapped.
//
// How the expected output follows from the standard:
// 1800.2-2020 1.4 (UVM-CASE-SENSITIVE-POOL-NAMES-101) gives the rule above.
// Setup: Use key101/Key101 with distinct values and a separate pool peer;
// delete the selected key, reinsert it and overwrite the other without
// creating a missing uppercase key. Expected: Only the exact selected key
// changes, the key count and traversal membership match each stage, and the
// independent peer retains both original values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_case_sensitive_pool_1_101;
  import uvm_pkg::*;
  localparam int VARIANT101=1;
  `include "pool101.svh"
endmodule
