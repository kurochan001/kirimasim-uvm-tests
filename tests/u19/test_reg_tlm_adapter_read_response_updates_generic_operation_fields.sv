/*
:name: test_reg_tlm_adapter_read_response_updates_generic_operation_fields
:description: failed read payload conversion preserves command and address and reports failure (IEEE 1800.2-2020 Section 19.2.2.2.2)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.2 19.2.1.2.6 19.1.2.1 19.1.2.2 19.1.2.3 19.1.2.5 19.1.2.6 12.3.4.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_read_response_updates_generic_operation_fields.expected
*/
// What it checks:
// The TLM adapter translates a failed read payload into generic read
// status/context.
//
// How the expected output follows from the standard:
// 1800.2-2020 19.2.2.2.2 (UVM-TLM-ADAPTER-READ-RESPONSE) gives the rule above.
// Setup: Provide explicit generic fields or a constructed payload and inspect
// the returned conversion. Expected: The result has READ kind, address 320 and
// UVM_NOT_OK.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe the command, address and failure status. Do not prescribe the
// data returned for an unsuccessful read operation.

module test_reg_tlm_adapter_read_response_updates_generic_operation_fields;
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
    payload.set_read();
    payload.set_response_status(UVM_TLM_GENERIC_ERROR_RESPONSE);
    adapter.bus2reg(payload, op);
    $display("UT: kind %0d address %0h status %0d",
             op.kind == UVM_READ, op.addr,
             op.status == UVM_NOT_OK);
    $finish;
  end
endmodule
