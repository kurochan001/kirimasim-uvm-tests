/*
:name: test_config_int_alias_matches_bitstream_type_and_preserves_high_selected_bits
:description: config int alias matches bitstream type and preserves high selected bits
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.3.1 C.4.2.2.1 C.4.2.2.2 F.2.1.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_int_alias_matches_bitstream_type_and_preserves_high_selected_bits.expected
*/
module test_config_int_alias_matches_bitstream_type_and_preserves_high_selected_bits;
  import uvm_pkg::*;
  initial begin
    uvm_bitstream_t value,read_back;
    bit found;
    value='0; value[127]=1; value[3]=1;
    uvm_config_int::set(null,"scope62","slot62",value);
    found=uvm_config_db#(uvm_bitstream_t)::get(null,"scope62","slot62",read_back);
    $display("UT: config_int exact_type %0d high_bits %0d",
      $typename(uvm_config_int)==$typename(uvm_config_db#(uvm_bitstream_t)),
      found && read_back==value);
    value='0; value[65]=1;
    uvm_config_db#(uvm_bitstream_t)::set(null,"scope62","slot62",value);
    found=uvm_config_int::get(null,"scope62","slot62",read_back);
    $display("UT: config_int reverse_route %0d",found && read_back==value);
    $finish;
  end
endmodule
