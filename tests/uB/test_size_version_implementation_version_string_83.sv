/*
:name: test_size_version_implementation_version_string_83
:description: The package provides a constant nonempty implementation version string without fixed vendor formatting
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.7.2  1800-2023 6.21 6.20 6.16 7.4 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_size_version_implementation_version_string_83.expected
*/
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_implementation_version_string_83;
  import uvm_pkg::*;
  localparam string COPY83=uvm_pkg::UVM_VERSION_STRING;
  initial begin
    $display("UT: version83 implementation nonempty %0d constant_copy %0d",
      uvm_pkg::UVM_VERSION_STRING.len()>0,COPY83==uvm_pkg::UVM_VERSION_STRING);
    $finish;
  end
endmodule
