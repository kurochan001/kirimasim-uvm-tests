/*
:name: test_reg_tlm_adapter_nonuniform_full_word_roundtrip_preserves_valid_operation_fields
:description: consistent adapter conversion preserves valid data and selected lane information (IEEE 1800.2-2020 Section 19.2.2.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.1 19.2.2.2.2 19.2.1.2.5 19.2.1.2.6 19.1.2.1 19.1.2.2 19.1.2.3 19.1.2.4 19.1.2.5 19.1.2.6 12.3.4.2.9 12.3.4.2.10 12.3.4.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_nonuniform_full_word_roundtrip_preserves_valid_operation_fields.expected
*/
// Compare with independent source scalar values after both conversions.
// No absolute payload byte order is prescribed. Disabled lanes and partial-
// byte
// padding are ignored; inverse reconstruction of n_bits remains open.
module test_reg_tlm_adapter_nonuniform_full_word_roundtrip_preserves_valid_operation_fields;
  import uvm_pkg::*;
  initial begin
    automatic uvm_reg_tlm_adapter adapter = new("adapter");
    uvm_reg_bus_op source, result;
    uvm_sequence_item item;
    uvm_tlm_gp payload;
    byte unsigned bytes[];
    source.kind = UVM_WRITE; source.addr = 'h135; source.data = 'h3ca57e19;
    source.n_bits = 32; source.byte_en = 'hF; source.status = UVM_IS_OK;
    item = adapter.reg2bus(source);
    if (!$cast(payload, item) || payload == null) $fatal(1, "wrong payload type");
    payload.get_data(bytes);
    $display("UT: payload covers_bits %0d readable_bytes %0d", payload.get_data_length()*8 >= 32,
             bytes.size() >= payload.get_data_length());
    result = source; result.kind = UVM_READ; result.addr = 0;
    result.data = '1; result.byte_en = 0; result.status = UVM_NOT_OK;
    payload.set_response_status(UVM_TLM_OK_RESPONSE); adapter.bus2reg(payload, result);
    $display("UT: roundtrip kind %0d address %0h data %0d enables %0h status %0d",
             result.kind == UVM_WRITE, result.addr, (result.data & 'hffffffff) == source.data,
             result.byte_en & 'hF, result.status == UVM_IS_OK);
    $finish;
  end
endmodule
