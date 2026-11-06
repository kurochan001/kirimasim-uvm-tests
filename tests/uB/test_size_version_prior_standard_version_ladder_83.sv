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
