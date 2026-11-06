/*
:name: test_size_version_field_flag_declared_bit_type_83
:description: The flag typedef has the declared unsigned bit-vector shape and legal reference compatibility
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.1.2 B.6.1 F.2.1.1 1800-2023 6.21 6.20 6.16 7.4 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_size_version_field_flag_declared_bit_type_83.expected
*/
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_field_flag_declared_bit_type_83;
  import uvm_pkg::*;
  function automatic void write_edges83(ref bit [`UVM_FIELD_FLAG_SIZE-1:0] value);
    value='0; value[0]=1; value[`UVM_FIELD_FLAG_SIZE-1]=1;
  endfunction
  initial begin
    automatic uvm_field_flag_t value='0;
    automatic uvm_field_flag_t ones='1;
    write_edges83(value);
    $display("UT: flag83 type left %0d right %0d unsigned %0d edges %0d",
      $left(value)==`UVM_FIELD_FLAG_SIZE-1,$right(value)==0,ones>0,
      value[0] && value[`UVM_FIELD_FLAG_SIZE-1]);
    $finish;
  end
endmodule
