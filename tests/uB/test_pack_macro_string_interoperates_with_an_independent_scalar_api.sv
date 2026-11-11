/*
:name: test_pack_macro_string_interoperates_with_an_independent_scalar_api
:description: Original uvm_pack_string packing interoperates with an independent scalar API and preserves a seven-bit trailer
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.4.8 5.3.10.2 5.3.11.2 16.5.2.1 16.5.3.3 16.5.4.5 16.5.4.7 16.5.4.8 16.5.4.9 16.5.4.13 16.5.4.15 16.5.4.16 16.5.4.17 1800-2023 6.21 6.24 8.20 8.21 13.5.2 21.2.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pack_macro_string_interoperates_with_an_independent_scalar_api.expected
*/
// What it checks:
// The selected scalar macro packs its value for independent API decoding.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.2.4.8 (UVM-MACRO-IO-AUDIT-PACK-STRING) gives the rule above.
// Setup: Invoke the scalar macro inside its named object hook with a
// compatible pinned packer instance; the other direction uses the public
// scalar API, followed by an independent seven-bit trailer. Expected: The
// selected scalar value and separate trailer match, with no bits left to
// unpack.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Expected values are original; no serialized stream layout is prescribed.
module
  test_pack_macro_string_interoperates_with_an_independent_scalar_api;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef enum bit [16:0] {COLD68=17'h12a,HOT68=17'h13a65} enum68;
  class subject68 extends uvm_object;
    string value="message68 with spaces";
    function new();super.new("subject68");endfunction
    virtual function void do_pack(uvm_packer packer);
      `uvm_pack_string(value);
    endfunction
  endclass
  initial begin
    automatic subject68 subject=new();
    automatic uvm_packer packer=new();
    automatic string decoded;
    automatic string expected_value="message68 with spaces";
    automatic uvm_integral_t tail;
    automatic bit remaining;
    subject.do_pack(packer);
    packer.pack_field_int('h35,7);
    decoded=packer.unpack_string();
    remaining=packer.get_packed_size()==7;tail=packer.unpack_field_int(7);
    $display("UT: %s value %0d tail %0d consumed %0d",
      "macro_pack_string",
      decoded==expected_value,tail=='h35,
      remaining && packer.get_packed_size()==0);
    $finish;
  end
endmodule
