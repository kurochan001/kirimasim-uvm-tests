/*
:name: test_reg_tlm_adapter_base_view_dispatches_consistent_payload_conversion
:description: reg tlm adapter base view dispatches consistent payload conversion (IEEE 1800.2-2020 Section 19.2.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.1 19.2.1.1 19.2.2.2.1 19.2.2.2.2 19.1.2.1 19.1.2.2 19.1.2.3 19.1.2.5 19.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_base_view_dispatches_consistent_payload_conversion.expected
*/
// What it checks:
// The TLM register adapter derives from the generic adapter.
//
// How the expected output follows from the standard:
// 1800.2-2020 19.2.2.1 (UVM-REG-INTERACTION-TLM-ADAPTER-BASE) gives the rule
// above. Setup: Use the actual TLM adapter through a generic-adapter handle
// for a selected sixteen-bit round trip. Expected: The base denotes the
// concrete adapter and dispatches consistent kind, address, valid data/enables
// and successful status conversion.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Call the concrete library adapter through its abstract base. Paired
// conversion checks valid fields, not independent one-way byte order, padding,
// inverse n_bits reconstruction or a parent_sequence cloning interpretation.
module test_reg_tlm_adapter_base_view_dispatches_consistent_payload_conversion;
  import uvm_pkg::*;
  initial begin
    automatic uvm_reg_tlm_adapter value = new();
    automatic uvm_reg_adapter base_view = value;
    uvm_reg_bus_op source, result;
    uvm_sequence_item item;
    uvm_tlm_gp payload;
    source.kind = UVM_WRITE; source.addr = 'h4e; source.data = 'ha17e;
    source.n_bits = 16; source.byte_en = 3; source.status = UVM_IS_OK;
    item = base_view.reg2bus(source);
    if (!$cast(payload, item) || payload == null) $fatal(1, "wrong generic payload");
    payload.set_response_status(UVM_TLM_OK_RESPONSE);
    result = source; result.kind = UVM_READ; result.addr = 0; result.data = 0;
    result.byte_en = 0; result.status = UVM_NOT_OK;
    base_view.bus2reg(payload, result);
    $display("UT: tlm_base identity %0d kind %0d addr %0d data %0d enables %0d status %0d",
             base_view == value, result.kind == UVM_WRITE, result.addr == 'h4e,
             (result.data & 'hffff) == 'ha17e, (result.byte_en & 3) == 3,
             result.status == UVM_IS_OK);
    $finish;
  end
endmodule
