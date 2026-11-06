/*
:name: test_size_version_standard_version_define_83
:description: The standard version macro is present and expands to the specified revision number
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.7.1  1800-2023 6.21 6.20 6.16 7.4 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_size_version_standard_version_define_83.expected
*/
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_standard_version_define_83;
  import uvm_pkg::*;
  initial begin
`ifdef UVM_VERSION
    $display("UT: version83 standard_define %0d",`UVM_VERSION==2020);
`else
    $display("UT: version83 standard_define 0");
`endif
    $finish;
  end
endmodule
