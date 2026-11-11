/*
:name: test_adapter_parent_sequence_register_write_replacement
:description: adapter-selected sequence bases execute register write with replacement (IEEE 1800.2-2020 Section 19.2.1.2.4)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.1.2.4 19.2.1.2.5 19.2.1.2.6 5.3.5.2 14.1.2.7 18.2.3.6 18.2.5.2 18.2.5.3 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.5.3.2 18.2.3.3 18.2.3.4 18.6.3.1 18.6.3.2 18.4.4.9 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers76/parent_sequence76.svh
:expected_exit: 0
:expected_stdout: @test_adapter_parent_sequence_register_write_replacement.expected
*/
// What it checks:
// When configured for a driver requiring a particular sequence base, the
// adapter parent_sequence supplies that required context for its bus items.
//
// How the expected output follows from the standard:
// 1800.2-2020 19.2.1.2.4 (UVM-ADAPTER-REQUIRED-PARENT-CONTEXT) gives the rule
// above. Setup: Original one-byte numeric-word frontdoors independently
// exercise register/memory reads/writes with no caller parent. Required-parent
// subtypes alternate A/B/A and current original tags 17/34/51. Paired inputs
// concurrently exercise two separate adapter/map/sequencer/driver routes; the
// peer retains base B/tag 119. A user clone override calls an original
// do_clone bridge; reads use independently seeded storage. Expected: The
// actual driver sees each required sequence base and the current fixture tag,
// completes the request successfully and transfers the selected byte. Both
// paired routes retain their independently selected contexts without imposing
// completion order.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Required parent bases use an original clone-to-do_clone bridge.
// No caller parent, clone count/identity, generated name or RTL is assumed.
module test_adapter_parent_sequence_register_write_replacement;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam bit MEMORY76 = 0;
  localparam bit READING76 = 0;
  localparam bit PAIRED76 = 0;
  `include "parent_sequence76.svh"
  initial run_test("t76");
  initial begin #100; $fatal(1, "original parent-context watchdog expired"); end
endmodule
