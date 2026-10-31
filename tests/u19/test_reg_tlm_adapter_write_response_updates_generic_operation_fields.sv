/*
:name: test_reg_tlm_adapter_write_response_updates_generic_operation_fields
:description: write payload conversion updates generic command address data enables and status (IEEE 1800.2-2020 Section 19.2.2.2.2)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.2 19.2.1.2.6 19.1.2.1 19.1.2.2 19.1.2.3 19.1.2.5 19.1.2.6 12.3.4.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_write_response_updates_generic_operation_fields.expected
*/
// Initialize the destination operation and use repeated bytes so numeric
// byte ordering cannot determine the result. Observe the response status.

module test_reg_tlm_adapter_write_response_updates_generic_operation_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_reg_tlm_adapter adapter = new("adapter");
    automatic uvm_tlm_gp payload = new("payload");
    automatic uvm_reg_bus_op op;
    byte unsigned bytes[];
    byte unsigned enables[];
    op.kind = UVM_WRITE;
    op.addr = 0;
    op.data = 0;
    op.n_bits = 7;
    op.byte_en = 0;
    op.status = UVM_NOT_OK;
    bytes = new[2];
    bytes[0] = 'hde;
    bytes[1] = 'hde;
    enables = new[2];
    enables[0] = 'hff;
    enables[1] = 'hff;
    payload.set_address('h320);
    payload.set_data(bytes);
    payload.set_data_length(2);
    payload.set_streaming_width(2);
    payload.set_byte_enable(enables);
    payload.set_byte_enable_length(2);
    payload.set_write();
    payload.set_response_status(UVM_TLM_OK_RESPONSE);
    adapter.bus2reg(payload, op);
    $display("UT: kind %0d address %0h data %0h enables %0h status %0d",
             op.kind == UVM_WRITE, op.addr, op.data, op.byte_en,
             op.status == UVM_IS_OK);
    $finish;
  end
endmodule
