/*
:name: test_random_stability_object_1_97
:description: Selected UVM calls without user hooks preserve relative caller and selected receiver RNG streams
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4.6 5.3.2 5.3.4.2 5.3.4.3 1800-2023 6.21 9.7 18.6.1 18.13.1 18.13.4 18.13.5 18.14
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers97/rng_stability97.svh
:expected_exit: 0
:expected_stdout: @test_random_stability_object_1_97.expected
*/
// What it checks:
// Selected inherited object-name queries preserve both the caller and receiver
// random streams when no user override is executed.
//
// Variant: Input 0 makes one library call per draw, with arguments 0 to 23.
// Input 1 first makes two warm-up calls and then two calls per draw with other
// arguments.
//
// How the expected output follows from the standard:
// 1800.2-2020 1.4.6 (UVM-RANDOM-STABILITY-OBJECT-NAME-STREAMS-97) gives the
// rule above. Setup: Construct an original object derivative with two
// unconstrained rand fields before measurement; use inherited
// get_name/get_full_name with no overrides or randomize hooks and confirm
// actual names and successful receiver randomizations. Replay a
// same-implementation saved calling-process RNG state against a no-UVM-call
// baseline of 24 future draws. Compare a cold 24-call history with a two-call
// warmup followed by 48 mixed/reversed calls; receiver construction and warmup
// precede the snapshot. Expected: Declared API observations and call counts
// match; every selected future calling-process draw agrees with its control.
// Every receiver randomization succeeds and both rand fields agree with the
// receiver-state replay control.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_random_stability_object_1_97;
  import uvm_pkg::*;
  localparam int FAMILY97=2;
  localparam int VARIANT97=1;
  localparam string FAMILY_NAME97="object";
  localparam string LABEL97="harbor97";
  `include "rng_stability97.svh"
endmodule
