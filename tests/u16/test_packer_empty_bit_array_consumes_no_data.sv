/*
:name: test_packer_empty_bit_array_consumes_no_data
:description: an empty bit array contributes no data before a subsequent array (IEEE 1800.2-2020 Section 16.5.4.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.1 16.5.4.18 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_empty_bit_array_consumes_no_data.expected
*/
// Packing an empty source and explicitly unpacking zero bits contribute no
// data. The following two-bit array remains at the same stream position.

module test_packer_empty_bit_array_consumes_no_data;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_packer packer = new;
    automatic bit empty_source[] = new[0];
    automatic bit source_bits[] = '{1, 0};
    automatic bit empty_target[] = new[0];
    automatic bit target_bits[] = new[2];
    packer.pack_bits(empty_source);
    packer.pack_bits(source_bits);
    packer.unpack_bits(empty_target, 0);
    packer.unpack_bits(target_bits);
    $display("UT: empty %0d data %0d%0d", empty_target.size(), target_bits[0], target_bits[1]);
    $finish;
  end
endmodule
