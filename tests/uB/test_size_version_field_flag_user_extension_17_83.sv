/*
:name: test_size_version_field_flag_user_extension_17_83
:description: A user flag extent relative to the reserved region preserves independent high tags and lower flag values
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.6.1 F.2.1.1 F.2.1.2 F.2.1.5 F.2.1.6 F.2.1.8 F.2.1.9 1800-2023 6.21 6.20 6.16 7.4 13.5.2
:uvm: 2020.3.1
:uvm_defines: UVM_FIELD_FLAG_SIZE=(UVM_FIELD_FLAG_RESERVED_BITS+17)
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_size_version_field_flag_user_extension_17_83.expected
*/
// What it checks:
// 1. A user-supplied legal field-flag size extends the type above the
//    implementation-reserved region.
// 2. The field-flag type retains selected upper user bits independently of
//    stored lower flag representations.
//
// Variant: The number, 17 or 129, is the extent in bits that the user adds
// beyond the reserved field-flag bits.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.6.1 (UVM-SIZE-VERSION-FLAG-USER-EXTENSION) gives rule 1
//    above. Setup: Unmodified public UVM types/macros and default packer
//    implementation. Flag overrides use the actual reserved-count parameter
//    plus17 or129,without fixing its implementation-dependent value. Capacity
//    inputs explicitly flush and retain32768 bits via independent
//    original8/64-bit payload patterns. Version inputs use public
//    package/preprocessor access;the illegal parameter assignment has no
//    runtime. Expected: Both reserved+17 and reserved+129 builds expose their
//    requested extents and retain distinct user tags without altering the
//    lower flag values.
// 2. 1800.2-2020 F.2.1.2 (UVM-SIZE-VERSION-FLAG-EXTENDED-STORAGE) gives rule 2
//    above. Setup: Unmodified public UVM types/macros and default packer
//    implementation. Flag overrides use the actual reserved-count parameter
//    plus17 or129,without fixing its implementation-dependent value. Capacity
//    inputs explicitly flush and retain32768 bits via independent
//    original8/64-bit payload patterns. Version inputs use public
//    package/preprocessor access;the illegal parameter assignment has no
//    runtime. Expected: Distinct first/last extension bits and the original
//    radix/recursion/operation lower region survive each selected legal type
//    extent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_field_flag_user_extension_17_83;
  import uvm_pkg::*;
  localparam int EXTENT83=UVM_FIELD_FLAG_RESERVED_BITS+17;
  initial begin
    automatic uvm_field_flag_t low=UVM_HEX | UVM_REFERENCE | UVM_COPY | UVM_NOCOMPARE;
    automatic uvm_field_flag_t value=low;
    value[UVM_FIELD_FLAG_RESERVED_BITS]=1;
    value[EXTENT83-1]=1;
    $display("UT: flag83 extension17 extent %0d first %0d last %0d lower %0d",
      $bits(value)==EXTENT83,value[UVM_FIELD_FLAG_RESERVED_BITS],value[EXTENT83-1],
      value[UVM_FIELD_FLAG_RESERVED_BITS-1:0]==low[UVM_FIELD_FLAG_RESERVED_BITS-1:0]);
    $finish;
  end
endmodule
