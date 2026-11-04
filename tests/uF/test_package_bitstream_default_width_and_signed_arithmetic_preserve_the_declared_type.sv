/*
:name: test_package_bitstream_default_width_and_signed_arithmetic_preserve_the_declared_type
:description: The bitstream type uses the selected stream width and signed arithmetic
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.1.3 B.6.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_bitstream_default_width_and_signed_arithmetic_preserve_the_declared_type.expected
*/
// Two-state width and signedness only; X/Z preservation remains separate.
module test_package_bitstream_default_width_and_signed_arithmetic_preserve_the_declared_type;
  import uvm_pkg::*;
  initial begin
    automatic uvm_bitstream_t negative=-1;
    automatic uvm_bitstream_t shifted=negative >>> 1;
    $display("UT: bitstream width %0d negative %0d arithmetic_sign %0d",
      $bits(negative)==`UVM_MAX_STREAMBITS,negative<0,shifted==negative);
    negative='0; negative[`UVM_MAX_STREAMBITS-1]=1;
    $display("UT: bitstream top_bit_negative %0d lower_bits_zero %0d",negative<0,
      (negative << 1)==0);
    $display("UT: bitstream selected_width %0d",$bits(negative)==4096);
    $finish;
  end
endmodule
