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
