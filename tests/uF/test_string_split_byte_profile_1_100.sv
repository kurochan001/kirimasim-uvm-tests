/*
:name: test_string_split_byte_profile_1_100
:description: Current string split preserves byte-delimited fields and replaces caller-owned queues across repeated edge cases
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.3.2 1800-2023 6.16 6.16.2 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_string_split_byte_profile_1_100.expected
:files: helpers100/split100.svh
*/
// What it checks:
// Repeated split calls replace the caller queue with the newly required token
// sequence.
//
// Variant: The number selects the separator byte: 0 uses ':' (8'h3a), 1 a
// space (8'h20), 2 the byte 8'h80 and 3 the byte 8'hff.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.3.3.2 (UVM-STRING-SPLIT-REUSED-OUTPUT-QUEUE-100) gives the
// rule above. Setup: Reuse a prefilled/mutated output queue through mixed,
// all-separator, no-match and empty input for each selected byte. Expected:
// Only the new ordered tokens remain at each stage; prior contents and caller
// mutations do not leak into later results.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_string_split_byte_profile_1_100;
  import uvm_pkg::*;
  localparam int PROFILE100=1;
  localparam byte SEPARATOR100=8'h20;
  `include "split100.svh"
endmodule
