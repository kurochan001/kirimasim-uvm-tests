/*
:name: test_packer_int_array_round_trip_preserves_high_bits
:description: integer array packing preserves full-width signed payload bits (IEEE 1800.2-2020 Section 16.5.4.11)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.11 16.5.4.12
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_int_array_round_trip_preserves_high_bits.expected
*/
// Pack the entire two-element source and unpack into a matching array.
// Compare decoded values without prescribing the internal stream layout.

module test_packer_int_array_round_trip_preserves_high_bits;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_packer packer = new;
    automatic int source_values[] = '{32'h80000001, 32'hffffffff};
    automatic int target_values[] = new[2];
    packer.pack_ints(source_values);
    packer.unpack_ints(target_values);
    $display("UT: values %08h %08h", target_values[0], target_values[1]);
    $finish;
  end
endmodule
