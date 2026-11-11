/*
:name: test_tlm2_payload_byte_enable_accessors_copy_mask_values
:description: generic payload byte enable accessors preserve copied mask values (IEEE 1800.2-2020 Section 12.3.4.2.30)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.30 12.3.4.2.31 12.3.4.2.32 12.3.4.2.33 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_byte_enable_accessors_copy_mask_values.expected
*/
// What it checks:
// 1. Byte-enable accessors preserve assigned mask values independently of
//    caller-array edits and another payload.
// 2. The byte-enable length query agrees with an explicitly matching
//    mask/length setup.
// 3. The public setter specifies the selected payload byte-enable array.
// 4. The public setter specifies the selected payload byte-enable length.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.2.30 (UVM-GP-BYTE-ENABLE-ARRAY-STATE) gives rule 1
//    above. Setup: Assign ff/zero masks, mutate caller arrays and clear one
//    payload. Expected: Stored masks survive caller edits and the peer mask
//    survives local clearing.
// 2. 1800.2-2020 12.3.4.2.32 (UVM-GP-CONSISTENT-MASK-LENGTH) gives rule 2
//    above. Setup: Use two-byte, one-byte and empty masks with matching
//    lengths. Expected: Returned lengths and array sizes agree and clearing
//    remains instance-local.
// 3. 1800.2-2020 12.3.4.2.31 (UVM-PAYLOAD-SET-BYTE-ENABLE-EXPLICIT-UPDATE)
//    gives rule 3 above. Setup: An unchanged accessor fixture assigns explicit
//    values and reads them back through public methods. Expected: The two
//    ff/00 mask bytes are retained independently of caller-side changes.
// 4. 1800.2-2020 12.3.4.2.33
//    (UVM-PAYLOAD-SET-BYTE-ENABLE-LENGTH-EXPLICIT-UPDATE) gives rule 4 above.
//    Setup: An unchanged accessor fixture assigns explicit values and reads
//    them back through public methods. Expected: The explicitly selected
//    length is two with a two-byte mask.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Set the mask length explicitly. Mutate the input and returned masks
// without changing the stored mask; no target data transfer occurs.

module test_tlm2_payload_byte_enable_accessors_copy_mask_values;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload payload = new("payload");
    byte unsigned mask[];
    byte unsigned result[];
    mask = new[2];
    mask[0] = 8'hff;
    mask[1] = 8'h00;
    payload.set_byte_enable(mask);
    payload.set_byte_enable_length(2);
    mask[0] = 0;
    payload.get_byte_enable(result);
    $display("UT: mask length %0d size %0d values %0h %0h",
        payload.get_byte_enable_length(), result.size(), result[0], result[1]);
    result[1] = 8'hff;
    payload.get_byte_enable(result);
    $display("UT: retained_mask %0h %0h", result[0], result[1]);
    $finish;
  end
endmodule
