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
// What it checks:
// 1. Payload address accessors preserve all assigned address bits
//    independently per instance.
// 2. The public setter specifies the selected payload address.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.2.22 (UVM-GP-ADDRESS-STATE) gives rule 1 above. Setup:
//    Assign distinct high-bit 64-bit addresses and zero one payload. Expected:
//    Both original addresses are exact and the unchanged payload retains its
//    address.
// 2. 1800.2-2020 12.3.4.2.23 (UVM-PAYLOAD-SET-ADDRESS-EXPLICIT-UPDATE) gives
//    rule 2 above. Setup: An unchanged accessor fixture assigns explicit
//    values and reads them back through public methods. Expected: Both
//    selected 64-bit addresses retain their high bits; replacing one with zero
//    preserves the peer.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
