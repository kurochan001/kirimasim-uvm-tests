/*
:name: test_size_version_field_flag_user_extension_129_83
:description: A user flag extent relative to the reserved region preserves independent high tags and lower flag values
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.6.1 F.2.1.1 F.2.1.2 F.2.1.5 F.2.1.6 F.2.1.8 F.2.1.9 1800-2023 6.21 6.20 6.16 7.4 13.5.2
:uvm: 2020.3.1
:uvm_defines: UVM_FIELD_FLAG_SIZE=(UVM_FIELD_FLAG_RESERVED_BITS+129)
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_size_version_field_flag_user_extension_129_83.expected
*/
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_field_flag_user_extension_129_83;
  import uvm_pkg::*;
  localparam int EXTENT83=UVM_FIELD_FLAG_RESERVED_BITS+129;
  initial begin
    automatic uvm_field_flag_t low=UVM_HEX | UVM_REFERENCE | UVM_COPY | UVM_NOCOMPARE;
    automatic uvm_field_flag_t value=low;
    value[UVM_FIELD_FLAG_RESERVED_BITS]=1;
    value[EXTENT83-1]=1;
    $display("UT: flag83 extension129 extent %0d first %0d last %0d lower %0d",
      $bits(value)==EXTENT83,value[UVM_FIELD_FLAG_RESERVED_BITS],value[EXTENT83-1],
      value[UVM_FIELD_FLAG_RESERVED_BITS-1:0]==low[UVM_FIELD_FLAG_RESERVED_BITS-1:0]);
    $finish;
  end
endmodule
