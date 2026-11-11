/*
:name: test_reg_tlm_adapter_reused_operation_preserve_conversion_contracts
:description: standard TLM adapter conversions preserve selected identity and operation fields (IEEE 1800.2-2020 Section 19.2.2.2.2)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.2 19.2.2.2.1 19.2.1.2.5 19.2.1.2.6 19.1.2.1 19.1.2.2 19.1.2.3 19.1.2.4 19.1.2.5 19.1.2.6 12.3.4.2.15 12.3.4.2.38 12.3.4.2.39 12.3.4.2.10 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_reused_operation_preserve_conversion_contracts.expected
*/
// What it checks:
// 1. Successful conversion replaces a previous failed operation status.
// 2. Reusing rw replaces its operation kind with the current payload command.
// 3. Reusing rw replaces a stale address with the current payload address.
// 4. Successful reuse converts the current valid data portion.
// 5. Successful conversion updates enabled valid byte lanes.
// 6. An error conversion replaces a previous successful generic status.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.1.2.6 (UVM-TLM-ADAPTER-REUSED-OP-SUCCESS) gives rule 1
//    above. Setup: One supplied rw object receives successful read, failed
//    read and successful write conversions. Expected: The initial read and
//    retry write both report IS_OK.
// 2. 1800.2-2020 19.1.2.1 (UVM-TLM-ADAPTER-REUSED-OP-COMMAND) gives rule 2
//    above. Setup: One supplied rw object receives successful read, failed
//    read and successful write conversions. Expected: The kind changes from
//    READ to WRITE.
// 3. 1800.2-2020 19.1.2.2 (UVM-TLM-ADAPTER-REUSED-OP-ADDRESS) gives rule 3
//    above. Setup: One supplied rw object receives successful read, failed
//    read and successful write conversions. Expected: Addresses become 0x700
//    then 0x710.
// 4. 1800.2-2020 19.1.2.3 (UVM-TLM-ADAPTER-REUSED-OP-DATA) gives rule 4 above.
//    Setup: One supplied rw object receives successful read, failed read and
//    successful write conversions. Expected: Low sixteen bits become 0x3c3c
//    then 0xa7a7.
// 5. 1800.2-2020 19.1.2.5 (UVM-TLM-ADAPTER-REUSED-OP-ENABLES) gives rule 5
//    above. Setup: One supplied rw object receives successful read, failed
//    read and successful write conversions. Expected: Both valid lanes are
//    enabled after starting with mask zero.
// 6. 1800.2-2020 19.1.2.6 (UVM-TLM-ADAPTER-REUSED-OP-FAILURE) gives rule 6
//    above. Setup: One supplied rw object receives successful read, failed
//    read and successful write conversions. Expected: The intervening address
//    error reports NOT_OK.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Uniform data/enable bytes avoid imposing numeric byte ordering.
// Failed-read data and unused upper data/mask bits are not constrained.
// The payload does not encode a sub-byte valid-bit count. No inverse
// n_bits value is prescribed here; that correspondence remains open.

module test_reg_tlm_adapter_reused_operation_preserve_conversion_contracts;
  import uvm_pkg::*;
  initial begin

    uvm_reg_tlm_adapter adapter;
    uvm_reg_bus_op rw;
    uvm_tlm_gp payload;
    uvm_sequence_item item;
    byte unsigned data_bytes[], enables[];

    adapter = new("adapter"); payload = new("payload");
      data_bytes = new[2]; data_bytes[0] = 'h3c; data_bytes[1] = 'h3c;
      enables = new[2]; enables[0] = 'hff; enables[1] = 'hff;
      payload.set_read(); payload.set_address('h700); payload.set_data(data_bytes);
      payload.set_data_length(2); payload.set_streaming_width(2);
      payload.set_byte_enable(enables); payload.set_byte_enable_length(2);
      rw.kind = UVM_WRITE; rw.addr = 0; rw.data = '1; rw.n_bits = 3;
      rw.byte_en = 0; rw.status = UVM_NOT_OK;
      payload.set_response_status(UVM_TLM_OK_RESPONSE); adapter.bus2reg(payload, rw);
      $display("UT: read ok %0d kind %0d address %0h low_data %0h enables %0h",
               rw.status == UVM_IS_OK, rw.kind == UVM_READ, rw.addr,
               rw.data & 'hffff, rw.byte_en & 'h3);
      payload.set_response_status(UVM_TLM_ADDRESS_ERROR_RESPONSE); adapter.bus2reg(payload, rw);
      $display("UT: error failed %0d", rw.status == UVM_NOT_OK);
      data_bytes[0] = 'ha7; data_bytes[1] = 'ha7;
      payload.set_write(); payload.set_address('h710); payload.set_data(data_bytes);
      payload.set_response_status(UVM_TLM_OK_RESPONSE); adapter.bus2reg(payload, rw);
      $display("UT: retry ok %0d kind %0d address %0h low_data %0h enables %0h",
               rw.status == UVM_IS_OK, rw.kind == UVM_WRITE, rw.addr,
               rw.data & 'hffff, rw.byte_en & 'h3);
    $finish;
  end
endmodule
