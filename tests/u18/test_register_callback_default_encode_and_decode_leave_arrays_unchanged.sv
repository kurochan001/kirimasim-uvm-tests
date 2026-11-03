/*
:name: test_register_callback_default_encode_and_decode_leave_arrays_unchanged
:description: register callback default encode and decode leave arrays unchanged (IEEE 1800.2-2020 Section 18.11.2.7)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.2.7 18.11.2.8 18.11.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_callback_default_encode_and_decode_leave_arrays_unchanged.expected
*/
// Call the actual default callback methods on nonempty and empty arrays. This
// control checks their no-change contract, not helper-chain data propagation.
module test_register_callback_default_encode_and_decode_leave_arrays_unchanged;
  import uvm_pkg::*;
  initial begin
    automatic uvm_reg_cbs subject = new();
    automatic uvm_reg_data_t values[];
    values = new[2]; values[0] = 'h13; values[1] = 'h25;
    subject.encode(values);
    $display("UT: default_encode size %0d values %0d",values.size(),
             values[0] == 'h13 && values[1] == 'h25);
    subject.decode(values);
    $display("UT: default_decode size %0d values %0d",values.size(),
             values[0] == 'h13 && values[1] == 'h25);
    values = new[0]; subject.encode(values); subject.decode(values);
    $display("UT: default_empty size %0d",values.size());
    $finish;
  end
endmodule
