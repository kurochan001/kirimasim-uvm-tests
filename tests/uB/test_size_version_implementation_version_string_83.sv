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
// What it checks:
// The UVM package exposes a string parameter for identifying its
// implementation.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.7.2 (UVM-SIZE-VERSION-IMPLEMENTATION-STRING-PARAMETER) gives
// the rule above. Setup: Unmodified public UVM types/macros and default packer
// implementation. Flag overrides use the actual reserved-count parameter
// plus17 or129,without fixing its implementation-dependent value. Capacity
// inputs explicitly flush and retain32768 bits via independent
// original8/64-bit payload patterns. Version inputs use public
// package/preprocessor access;the illegal parameter assignment has no runtime.
// Expected: The public string supports its string-length query,has nonempty
// contents and can be copied into a local constant with equal value.
// It also supports, as a control, the setup or conditions of
// UVM-SIZE-VERSION-IMPLEMENTATION-PARAMETER-IMMUTABILITY.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
