/*
:name: test_packer_empty_string_preserves_following_fields
:description: an empty packed string does not consume the following string or integer (IEEE 1800.2-2020 Section 16.5.4.5)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.5 16.5.4.13 16.5.4.9 16.5.4.17 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_empty_string_preserves_following_fields.expected
*/
// Round-trip an empty string before a nonempty string and an integral
// field. Observe values only, without relying on a byte stream layout.

module test_packer_empty_string_preserves_following_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_packer packer = new;
    string empty;
    string text;
    uvm_integral_t value;
    packer.pack_string("");
    packer.pack_string("done");
    packer.pack_field_int(42, 8);
    empty = packer.unpack_string();
    text = packer.unpack_string();
    value = packer.unpack_field_int(8);
    $display("UT: empty %0d text %s value %0d", empty == "", text, value);
    $finish;
  end
endmodule
