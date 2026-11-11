/*
:name: test_field_macro_explicit_unpack_flag_control_preserves_the_selected_roundtrip
:description: An explicit UNPACK flag control retains the compatible selected field roundtrip
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.2 F.2.1.8 F.2.1.9 B.2.2.1.1 5.3.10.1 5.3.11.1 1800-2023 6.21 8.20 8.21 7.4 7.8 7.9 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_macro_explicit_unpack_flag_control_preserves_the_selected_roundtrip.expected
*/
// What it checks:
// It is a control: it supports the setup or conditions of these duties, which
// other tests check directly:
// 1. PACK enables both packing and unpacking of the selected field.
// 2. NOPACK overrides selected positive flags and suppresses both directions.
// 3. NOPACK removes the selected field from both packing and unpacking.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.2.2 (UVM-FIELD-MACRO-AUDIT-PACK-ENABLES-UNPACK) gives rule
//    1 above. Setup: Use distinct enabled/excluded fields or omitted/explicit
//    flags in an original registered class without user operation hooks;
//    independently initialize source and target. Expected: The PACK-only field
//    returns to the selected original value after unpack using a compatible
//    private stream.
// 2. 1800.2-2020 B.2.2 (UVM-FIELD-MACRO-AUDIT-NOPACK-PAIRED-OVERRIDE) gives
//    rule 2 above. Setup: Use distinct enabled/excluded fields or
//    omitted/explicit flags in an original registered class without user
//    operation hooks; independently initialize source and target. Expected:
//    The excluded target retains its independent sentinel after unpack while
//    the enabled field transfers.
// 3. 1800.2-2020 F.2.1.9 (UVM-FIELD-MACRO-AUDIT-NOPACK-MEANING) gives rule 3
//    above. Setup: Use distinct enabled/excluded fields or omitted/explicit
//    flags in an original registered class without user operation hooks;
//    independently initialize source and target. Expected: The selected
//    suppressed field does not overwrite the target sentinel.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Control-only: explicitly add UNPACK without changing the original oracle.
module test_field_macro_explicit_unpack_flag_control_preserves_the_selected_roundtrip;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_object;
    bit [7:0] enabled, suppressed;
    `uvm_object_utils_begin(packet)
      `uvm_field_int(enabled,UVM_PACK|UVM_UNPACK)
      `uvm_field_int(suppressed,UVM_PACK|UVM_UNPACK|UVM_ALL_ON|UVM_NOPACK)
    `uvm_object_utils_end
    function new(string name="packet65"); super.new(name); endfunction
  endclass
  initial begin
    automatic packet source=new(), target=new();
    automatic uvm_packer packer=new();
    bit stream[];
    int packed_count,unpacked_count;
    source.enabled='h91; source.suppressed='hc3;
    target.enabled='h27; target.suppressed='h5a;
    packed_count=source.pack(stream,packer);
    unpacked_count=target.unpack(stream,packer);
    $display("UT: paired_pack positive %0d matched_count %0d selected %0d suppressed %0d",
      packed_count>0,packed_count==unpacked_count,target.enabled=='h91,target.suppressed=='h5a);
    $finish;
  end
endmodule
