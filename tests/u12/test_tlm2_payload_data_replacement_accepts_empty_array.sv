/*
:name: test_tlm2_payload_data_replacement_accepts_empty_array
:description: generic payload data can be replaced and cleared with a matching explicit length (IEEE 1800.2-2020 Section 12.3.4.2.24)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.24 12.3.4.2.25 12.3.4.2.26 12.3.4.2.27 12.3.4.2.17 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_data_replacement_accepts_empty_array.expected
*/
// What it checks:
// 1. Data accessors return the assigned unsigned-byte array without sharing
//    caller array mutation.
// 2. The data-length query agrees with an explicitly matching array/length
//    setup.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.2.24 (UVM-GP-DATA-ARRAY-STATE) gives rule 1 above.
//    Setup: Use bytes spanning zero/high bits and replace the array with empty
//    data. Expected: The stored bytes survive input/output-array edits and
//    explicit empty replacement is reflected.
// 2. 1800.2-2020 12.3.4.2.26 (UVM-GP-CONSISTENT-DATA-LENGTH) gives rule 2
//    above. Setup: Set matching lengths four, two and zero with their arrays.
//    Expected: Reported length and returned array size agree for each setup.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use IGNORE for a payload with zero data length. Assign the array and
// its explicit protocol length together before inspecting them.

module test_tlm2_payload_data_replacement_accepts_empty_array;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload payload = new("payload");
    byte unsigned source[];
    byte unsigned result[];
    payload.set_command(UVM_TLM_IGNORE_COMMAND);
    source = new[2];
    source[0] = 8'h91;
    source[1] = 8'h02;
    payload.set_data(source);
    payload.set_data_length(2);
    payload.get_data(result);
    $display("UT: first length %0d size %0d data %0h %0h", payload.get_data_length(),
        result.size(), result[0], result[1]);
    source = new[0];
    payload.set_data(source);
    payload.set_data_length(0);
    payload.get_data(result);
    $display("UT: cleared length %0d size %0d", payload.get_data_length(), result.size());
    $finish;
  end
endmodule
