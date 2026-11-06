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
