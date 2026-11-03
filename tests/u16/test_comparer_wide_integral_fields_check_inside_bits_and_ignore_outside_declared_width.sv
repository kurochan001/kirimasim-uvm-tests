/*
:name: test_comparer_wide_integral_fields_check_inside_bits_and_ignore_outside_declared_width
:description: comparer wide integral fields check inside bits and ignore outside declared width
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.1 16.3.3.9 B.6.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_wide_integral_fields_check_inside_bits_and_ignore_outside_declared_width.expected
*/
module test_comparer_wide_integral_fields_check_inside_bits_and_ignore_outside_declared_width;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  initial begin
    automatic int widths[5]='{1,64,65,129,`UVM_MAX_STREAMBITS};
    foreach (widths[i]) begin
      automatic uvm_comparer comparer=new();
      automatic uvm_bitstream_t lhs='0,rhs='0;
      bit equal_value,mismatch,outside_equal,outside_checked;
      equal_value=comparer.compare_field("equal",lhs,rhs,widths[i],UVM_HEX);
      lhs[widths[i]-1]=1;
      mismatch=comparer.compare_field("inside",lhs,rhs,widths[i],UVM_HEX);
      outside_checked=widths[i]<$bits(rhs); outside_equal=0;
      if (outside_checked) begin
        lhs='0; rhs[widths[i]]=1;
        outside_equal=comparer.compare_field("outside",lhs,rhs,widths[i],UVM_HEX);
      end
      $display("UT: wide_compare %0d equal %0d mismatch %0d count %0d checked %0d outside %0d",
               i,equal_value,mismatch,comparer.get_result(),outside_checked,outside_equal);
    end
    $finish;
  end
endmodule
