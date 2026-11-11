/*
:name: test_size_version_prior_standard_version_ladder_83
:description: The standard revision ladder provides the post-2017 presence define
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.7.3  1800-2023 6.21 6.20 6.16 7.4 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_size_version_prior_standard_version_ladder_83.expected
*/
// What it checks:
// The revision ladder supplies the defined post-2017 indicator for the current
// standard.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.7.3 (UVM-SIZE-VERSION-POST-2017-LADDER) gives the rule above.
// Setup: Unmodified public UVM types/macros and default packer implementation.
// Flag overrides use the actual reserved-count parameter plus17 or129,without
// fixing its implementation-dependent value. Capacity inputs explicitly flush
// and retain32768 bits via independent original8/64-bit payload patterns.
// Version inputs use public package/preprocessor access;the illegal parameter
// assignment has no runtime. Expected: UVM_VERSION_POST_2017 is visible to a
// conditional-compilation presence test without assigning any numeric value to
// this presence macro.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_prior_standard_version_ladder_83;
  import uvm_pkg::*;
  initial begin
`ifdef UVM_VERSION_POST_2017
    $display("UT: version83 post2017_present 1");
`else
    $display("UT: version83 post2017_present 0");
`endif
    $finish;
  end
endmodule
