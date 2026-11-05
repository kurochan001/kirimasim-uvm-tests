/*
:name: test_record_macro_control_direct_small_field_preserves_default_and_explicit_radices
:description: Direct 33-bit record_field calls reach the field hook with default BIN and explicit HEX radices
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.4.6.1 16.4.2.3 16.4.7.4 5.4.2.4 5.4.2.6 5.4.2.8 16.4.2.1 16.4.5.1 16.4.5.2 7.1.3.1 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.5.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: ../uB/helpers68/recording_fixture68.svh
:expected_exit: 0
:expected_stdout: @test_record_macro_control_direct_small_field_preserves_default_and_explicit_radices.expected
*/
// Original policy hooks distinguish public field calls from macro dispatch.
module test_record_macro_control_direct_small_field_preserves_default_and_explicit_radices;
  import uvm_pkg::*;
  `include "recording_fixture68.svh"
  initial begin
    automatic recorder68 recorder=new();
    automatic transaction68 transaction=new();
    automatic bit [32:0] value=33'h1cdef0123;
    automatic bit default_ok,explicit_ok;
    activate68(recorder,transaction);recorder.set_default_radix(UVM_BIN);
    recorder.record_field("tag68",value,33);
    default_ok=recorder.field_calls==1 && recorder.int_calls==0 &&
      recorder.field_name=="tag68" && recorder.field_value==value && recorder.field_size==33 &&
      (recorder.field_radix==UVM_NORADIX || recorder.field_radix==UVM_BIN);
    recorder.clear68();recorder.record_field("tag68",value,33,UVM_HEX);
    explicit_ok=recorder.field_calls==1 && recorder.int_calls==0 &&
      recorder.field_name=="tag68" && recorder.field_value==value && recorder.field_size==33 &&
      recorder.field_radix==UVM_HEX;
    $display("UT: record_direct33 default %0d explicit %0d",default_ok,explicit_ok);
    transaction.end_tr();$finish;
  end
endmodule
