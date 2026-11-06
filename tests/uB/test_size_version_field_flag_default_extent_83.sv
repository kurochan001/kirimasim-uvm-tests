/*
:name: test_size_version_field_flag_default_extent_83
:description: The default flag extent agrees with its macro and accommodates the reserved bit count
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.6.1 F.2.1.1 F.2.1.2 1800-2023 6.21 6.20 6.16 7.4 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_size_version_field_flag_default_extent_83.expected
*/
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_field_flag_default_extent_83;
  import uvm_pkg::*;
  initial begin
    automatic uvm_field_flag_t value='0;
    $display("UT: flag83 default extent %0d reserved %0d",
      $bits(value)==`UVM_FIELD_FLAG_SIZE,`UVM_FIELD_FLAG_SIZE>=UVM_FIELD_FLAG_RESERVED_BITS);
    $finish;
  end
endmodule
