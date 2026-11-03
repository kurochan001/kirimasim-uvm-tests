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
