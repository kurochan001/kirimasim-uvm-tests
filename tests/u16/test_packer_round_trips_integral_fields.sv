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
