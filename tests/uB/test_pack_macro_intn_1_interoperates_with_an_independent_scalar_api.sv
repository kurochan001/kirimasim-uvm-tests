/*
:name: test_pack_macro_intn_1_interoperates_with_an_independent_scalar_api
:description: Original uvm_pack_intN packing interoperates with an independent scalar API and preserves a seven-bit trailer
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.4 B.2.4.1 5.3.10.2 5.3.11.2 16.5.2.1 16.5.3.3 16.5.4.5 16.5.4.7 16.5.4.8 16.5.4.9 16.5.4.13 16.5.4.15 16.5.4.16 16.5.4.17 1800-2023 6.21 6.24 8.20 8.21 13.5.2 21.2.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pack_macro_intn_1_interoperates_with_an_independent_scalar_api.expected
*/
// Expected values are original; no serialized stream layout is prescribed.
module
  test_pack_macro_intn_1_interoperates_with_an_independent_scalar_api;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef enum bit [16:0] {COLD68=17'h12a,HOT68=17'h13a65} enum68;
  class subject68 extends uvm_object;
    bit [96:0] value=(97'h1<<96)|97'h123456789abcdef;
    function new();super.new("subject68");endfunction
    virtual function void do_pack(uvm_packer packer);
      `uvm_pack_intN(value,1);
    endfunction
  endclass
  initial begin
    automatic subject68 subject=new();
    automatic uvm_packer packer=new();
    automatic uvm_bitstream_t decoded;
    automatic bit [96:0] expected_value=(97'h1<<96)|97'h123456789abcdef;
    automatic uvm_integral_t tail;
    automatic bit remaining;
    subject.do_pack(packer);
    packer.pack_field_int('h35,7);
    decoded=packer.unpack_field(1);
    remaining=packer.get_packed_size()==7;tail=packer.unpack_field_int(7);
    $display("UT: %s value %0d tail %0d consumed %0d",
      "macro_pack_intn_1",
      decoded==(uvm_bitstream_t'(expected_value)&uvm_bitstream_t'((97'h1<<1)-1)),tail=='h35,
      remaining && packer.get_packed_size()==0);
    $finish;
  end
endmodule
