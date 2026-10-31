/*
:name: test_tlm2_payload_byte_enable_replacement_and_clear_are_local
:description: generic payload byte enable replacement and clearing leave another payload unchanged (IEEE 1800.2-2020 Section 12.3.4.2.30)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.30 12.3.4.2.31 12.3.4.2.32 12.3.4.2.33 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_byte_enable_replacement_and_clear_are_local.expected
*/
// Assign matching array and length values on two payloads, then clear
// only one. No expectation covers independently mismatched lengths.

module test_tlm2_payload_byte_enable_replacement_and_clear_are_local;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload first = new("first");
    automatic uvm_tlm_generic_payload second = new("second");
    byte unsigned mask[];
    byte unsigned result[];
    mask = new[1];
    mask[0] = 8'hff;
    first.set_byte_enable(mask);
    first.set_byte_enable_length(1);
    second.set_byte_enable(mask);
    second.set_byte_enable_length(1);
    mask = new[0];
    first.set_byte_enable(mask);
    first.set_byte_enable_length(0);
    first.get_byte_enable(result);
    $display("UT: first length %0d size %0d", first.get_byte_enable_length(), result.size());
    second.get_byte_enable(result);
    $display("UT: second length %0d size %0d value %0h", second.get_byte_enable_length(),
        result.size(), result[0]);
    $finish;
  end
endmodule
