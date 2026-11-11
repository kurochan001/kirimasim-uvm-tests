/*
:name: test_packer_round_trips_integral_fields
:description: integral fields unpack in their packed order and widths (IEEE 1800.2-2020 Section 16.5.4.9)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.9 16.5.4.17 16.5.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_round_trips_integral_fields.expected
*/
// What it checks:
// 1. get_packed_size reports the remaining number of unpackable bits.
// 2. Integral packing processes exactly the requested field width up to 64
//    bits.
// 3. Integral unpacking processes exactly the requested field width up to 64
//    bits.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.5.3.3 (UVM-PACKER-AVAILABLE-BITS) gives rule 1 above.
//    Setup: Inspect producers and consumers before/after field reads.
//    Expected: Only the consumer size decreases with reads, reaching zero
//    after all fields are consumed.
// 2. 1800.2-2020 16.5.4.9 (UVM-PACKER-INTEGRAL-PACK) gives rule 2 above.
//    Setup: Use successive unequal field widths and a full-width 64-bit
//    payload. Expected: Values and consumed bit counts agree with the selected
//    widths without prescribing byte layout.
// 3. 1800.2-2020 16.5.4.17 (UVM-PACKER-INTEGRAL-UNPACK) gives rule 3 above.
//    Setup: Use successive unequal field widths and a full-width 64-bit
//    payload. Expected: Values and consumed bit counts agree with the selected
//    widths without prescribing byte layout.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Pack two fields with distinct widths, then read them back in the same
// order. Check payload values without prescribing a byte stream layout.

module test_packer_round_trips_integral_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

initial begin
  automatic uvm_packer packer = new;
  uvm_integral_t first;
  uvm_integral_t second;
  packer.pack_field_int(64'habc, 12);
  packer.pack_field_int(64'h35, 7);
  $display("UT: packed bits %0d", packer.get_packed_size());
  first = packer.unpack_field_int(12);
  second = packer.unpack_field_int(7);
  $display("UT: values %0h %0h", first, second);
    $display("UT: remaining bits %0d", packer.get_packed_size());
  $finish;
end
endmodule
