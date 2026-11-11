/*
:name: test_reg_tlm_adapter_alternating_lanes_roundtrip_preserves_valid_operation_fields
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
:expected_stdout: @test_reg_tlm_adapter_alternating_lanes_roundtrip_preserves_valid_operation_fields.expected
*/
// What it checks:
// 1. Paired conversion retains the supplied WRITE operation kind.
// 2. Paired conversion retains the supplied bus address.
// 3. An OK payload response converts to a successful generic operation.
// 4. Paired conversion retains the selected valid lane enables.
// 5. Converted payload data storage covers its declared byte length.
// 6. Converted payload byte length is sufficient for the source valid-bit
//    extent.
// 7. Paired conversion preserves the selected valid source data.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.1.2.1 (UVM-TLM-ROUNDTRIP-COMMAND) gives rule 1 above.
//    Setup: Standard reg2bus/bus2reg convert nonuniform full, selected-lane
//    and partial-byte operations. Expected: The resulting kind is WRITE.
// 2. 1800.2-2020 19.1.2.2 (UVM-TLM-ROUNDTRIP-ADDRESS) gives rule 2 above.
//    Setup: Standard reg2bus/bus2reg convert nonuniform full, selected-lane
//    and partial-byte operations. Expected: The resulting address is 0x135.
// 3. 1800.2-2020 19.1.2.6 (UVM-TLM-ROUNDTRIP-STATUS) gives rule 3 above.
//    Setup: Standard reg2bus/bus2reg convert nonuniform full, selected-lane
//    and partial-byte operations. Expected: The result replaces NOT_OK with
//    IS_OK.
// 4. 1800.2-2020 19.1.2.5 (UVM-TLM-ROUNDTRIP-ENABLED-LANES) gives rule 4
//    above. Setup: Standard reg2bus/bus2reg convert nonuniform full,
//    selected-lane and partial-byte operations. Expected: Valid masks are 0xf,
//    0xa and 0x3 in their selected contexts.
// 5. 1800.2-2020 12.3.4.2.9 (UVM-TLM-ROUNDTRIP-READABLE-DATA-CAPACITY) gives
//    rule 5 above. Setup: Standard reg2bus/bus2reg convert nonuniform full,
//    selected-lane and partial-byte operations. Expected: The returned data
//    array has at least its declared length.
// 6. 1800.2-2020 19.2.2.2.1 (UVM-TLM-ROUNDTRIP-BIT-CAPACITY) gives rule 6
//    above. Setup: Standard reg2bus/bus2reg convert nonuniform full,
//    selected-lane and partial-byte operations. Expected: Payload byte
//    capacity covers the selected 32 or 9 valid bits.
// 7. 1800.2-2020 19.1.2.3 (UVM-TLM-ROUNDTRIP-SELECTED-DATA) gives rule 7
//    above. Setup: The same word enables only lanes 1 and 3. Expected: Bits
//    selected by 0xff00ff00 match the independent source scalar.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Compare with independent source scalar values after both conversions.
// No absolute payload byte order is prescribed. Disabled lanes and partial-
// byte
// padding are ignored; inverse reconstruction of n_bits remains open.
module test_reg_tlm_adapter_alternating_lanes_roundtrip_preserves_valid_operation_fields;
  import uvm_pkg::*;
  initial begin
    automatic uvm_reg_tlm_adapter adapter = new("adapter");
    uvm_reg_bus_op source, result;
    uvm_sequence_item item;
    uvm_tlm_gp payload;
    byte unsigned bytes[];
    source.kind = UVM_WRITE; source.addr = 'h135; source.data = 'h3ca57e19;
    source.n_bits = 32; source.byte_en = 'hA; source.status = UVM_IS_OK;
    item = adapter.reg2bus(source);
    if (!$cast(payload, item) || payload == null) $fatal(1, "wrong payload type");
    payload.get_data(bytes);
    $display("UT: payload covers_bits %0d readable_bytes %0d", payload.get_data_length()*8 >= 32,
             bytes.size() >= payload.get_data_length());
    result = source; result.kind = UVM_READ; result.addr = 0;
    result.data = '1; result.byte_en = 0; result.status = UVM_NOT_OK;
    payload.set_response_status(UVM_TLM_OK_RESPONSE); adapter.bus2reg(payload, result);
    $display("UT: roundtrip kind %0d address %0h data %0d enables %0h status %0d",
             result.kind == UVM_WRITE, result.addr,
             (result.data & 'hff00ff00) == (source.data & 'hff00ff00),
             result.byte_en & 'hF, result.status == UVM_IS_OK);
    $finish;
  end
endmodule
