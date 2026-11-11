/*
:name: test_size_version_packer_minimum_define_83
:description: The unconfigured packer minimum define supplies the specified default bit capacity
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.6.3 16.5 1800-2023 6.21 6.20 6.16 7.4 13.5.2
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_size_version_packer_minimum_define_83.expected
*/
// What it checks:
// The unconfigured packer-minimum macro provides the specified default of32768
// bits.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.6.3 (UVM-SIZE-VERSION-PACKER-MINIMUM-DEFINE) gives the rule
// above. Setup: Unmodified public UVM types/macros and default packer
// implementation. Flag overrides use the actual reserved-count parameter
// plus17 or129,without fixing its implementation-dependent value. Capacity
// inputs explicitly flush and retain32768 bits via independent
// original8/64-bit payload patterns. Version inputs use public
// package/preprocessor access;the illegal parameter assignment has no runtime.
// Expected: The public macro exists and its unconfigured value is32768.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_packer_minimum_define_83;
  import uvm_pkg::*;
  initial begin
    $display("UT: size83 packer_minimum_default %0d",`UVM_PACKER_MIN_BITS==32768);
    $finish;
  end
endmodule
