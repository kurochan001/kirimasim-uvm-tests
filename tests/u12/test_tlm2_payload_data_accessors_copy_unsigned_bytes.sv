/*
:name: test_tlm2_payload_data_accessors_copy_unsigned_bytes
:description: generic payload data setters and getters retain copied unsigned byte values (IEEE 1800.2-2020 Section 12.3.4.2.24)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.24 12.3.4.2.25 12.3.4.2.26 12.3.4.2.27 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_data_accessors_copy_unsigned_bytes.expected
*/
// Set a consistent data length explicitly. Mutating the source array
// or a returned array must not change the stored data value.

module test_tlm2_payload_data_accessors_copy_unsigned_bytes;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload payload = new("payload");
    byte unsigned source[];
    byte unsigned result[];
    source = new[4];
    source[0] = 8'h00;
    source[1] = 8'h7f;
    source[2] = 8'h80;
    source[3] = 8'hff;
    payload.set_data(source);
    payload.set_data_length(4);
    source[0] = 8'h55;
    payload.get_data(result);
    $display("UT: length %0d array_size %0d data %0h %0h %0h %0h",
        payload.get_data_length(), result.size(),
             result[0], result[1], result[2], result[3]);
    result[3] = 0;
    payload.get_data(result);
    $display("UT: retained_last %0h", result[3]);
    $finish;
  end
endmodule
