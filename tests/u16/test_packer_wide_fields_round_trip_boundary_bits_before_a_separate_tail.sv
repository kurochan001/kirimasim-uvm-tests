/*
:name: test_packer_wide_fields_round_trip_boundary_bits_before_a_separate_tail
:description: packer wide fields round trip boundary bits before a separate tail
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.8 16.5.4.16 16.5.3.3 B.6.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_wide_fields_round_trip_boundary_bits_before_a_separate_tail.expected
*/
module test_packer_wide_fields_round_trip_boundary_bits_before_a_separate_tail;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  initial begin
    automatic int widths[4]='{64,65,129,`UVM_MAX_STREAMBITS};
    foreach (widths[i]) begin
      automatic uvm_packer packer=new();
      automatic uvm_bitstream_t input_value='0;
      uvm_bitstream_t restored;
      uvm_integral_t tail;
      int before_tail;
      input_value[widths[i]-1]=1; input_value[0]=1;
      packer.pack_field(input_value,widths[i]); packer.pack_field_int('h35,7);
      before_tail=packer.get_packed_size(); restored=packer.unpack_field(widths[i]);
      tail=packer.unpack_field_int(7);
      $display("UT: wide_pack %0d count %0d value %0d tail %0d empty %0d",i,
               before_tail==widths[i]+7,restored==input_value,tail=='h35,
               packer.get_packed_size()==0);
    end
    $finish;
  end
endmodule
