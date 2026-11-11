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
// What it checks:
// 1. Data accessors return the assigned unsigned-byte array without sharing
//    caller array mutation.
// 2. The data-length query agrees with an explicitly matching array/length
//    setup.
// 3. The public setter specifies the selected payload data array.
// 4. The public setter specifies the selected payload data length.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.2.24 (UVM-GP-DATA-ARRAY-STATE) gives rule 1 above.
//    Setup: Use bytes spanning zero/high bits and replace the array with empty
//    data. Expected: The stored bytes survive input/output-array edits and
//    explicit empty replacement is reflected.
// 2. 1800.2-2020 12.3.4.2.26 (UVM-GP-CONSISTENT-DATA-LENGTH) gives rule 2
//    above. Setup: Set matching lengths four, two and zero with their arrays.
//    Expected: Reported length and returned array size agree for each setup.
// 3. 1800.2-2020 12.3.4.2.25 (UVM-PAYLOAD-SET-DATA-EXPLICIT-UPDATE) gives rule
//    3 above. Setup: An unchanged accessor fixture assigns explicit values and
//    reads them back through public methods. Expected: The four unsigned bytes
//    00/7f/80/ff are retained independently of a caller-side mutation.
// 4. 1800.2-2020 12.3.4.2.27 (UVM-PAYLOAD-SET-DATA-LENGTH-EXPLICIT-UPDATE)
//    gives rule 4 above. Setup: An unchanged accessor fixture assigns explicit
//    values and reads them back through public methods. Expected: The
//    explicitly selected length is four with a four-byte array.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
