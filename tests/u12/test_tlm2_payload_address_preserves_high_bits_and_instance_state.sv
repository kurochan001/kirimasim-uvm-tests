/*
:name: test_tlm2_payload_address_preserves_high_bits_and_instance_state
:description: generic payload addresses preserve all 64 bits and update independently (IEEE 1800.2-2020 Section 12.3.4.2.22)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.22 12.3.4.2.23 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_address_preserves_high_bits_and_instance_state.expected
*/
// Use unsigned 64-bit addresses with high bits set, then update only
// one payload. Addresses are data here, without a modeled target memory.

module test_tlm2_payload_address_preserves_high_bits_and_instance_state;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload first = new("first");
    automatic uvm_tlm_generic_payload second = new("second");
    first.set_address(64'hfedcba9876543210);
    second.set_address(64'h8000000012345678);
    $display("UT: addresses %0h %0h", first.get_address(), second.get_address());
    first.set_address(0);
    $display("UT: updated %0h retained %0h", first.get_address(), second.get_address());
    $finish;
  end
endmodule
