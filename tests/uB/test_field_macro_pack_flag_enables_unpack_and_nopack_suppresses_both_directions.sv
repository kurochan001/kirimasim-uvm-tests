/*
:name: test_field_macro_pack_flag_enables_unpack_and_nopack_suppresses_both_directions
:description: PACK enables both directions while NOPACK overrides every selected positive pack flag
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.2 F.2.1.8 F.2.1.9 B.2.2.1.1 5.3.10.1 5.3.11.1 1800-2023 6.21 8.20 8.21 7.4 7.8 7.9 8.19
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_macro_pack_flag_enables_unpack_and_nopack_suppresses_both_directions.expected
*/
// The stream is private to compatible packers; no metadata encoding is imposed.
module test_field_macro_pack_flag_enables_unpack_and_nopack_suppresses_both_directions;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_object;
    bit [7:0] enabled, suppressed;
    `uvm_object_utils_begin(packet)
      `uvm_field_int(enabled,UVM_PACK)
      `uvm_field_int(suppressed,UVM_PACK|UVM_UNPACK|UVM_ALL_ON|UVM_NOPACK)
    `uvm_object_utils_end
    function new(string name="packet65"); super.new(name); endfunction
  endclass
  initial begin
    automatic packet source=new(), target=new();
    automatic uvm_packer packer=new();
    bit stream[];
    int packed_count,unpacked_count;
    source.enabled='h91; source.suppressed='hc3;
    target.enabled='h27; target.suppressed='h5a;
    packed_count=source.pack(stream,packer);
    unpacked_count=target.unpack(stream,packer);
    $display("UT: paired_pack positive %0d matched_count %0d selected %0d suppressed %0d",
      packed_count>0,packed_count==unpacked_count,target.enabled=='h91,target.suppressed=='h5a);
    $finish;
  end
endmodule
