/*
:name: test_reg_tlm_adapter_error_statuses_preserve_conversion_contracts
:description: standard TLM adapter conversions preserve selected identity and operation fields (IEEE 1800.2-2020 Section 19.2.2.2.2)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.2 19.2.2.2.1 19.2.1.2.5 19.2.1.2.6 19.1.2.1 19.1.2.2 19.1.2.3 19.1.2.4 19.1.2.5 19.1.2.6 12.3.4.2.15 12.3.4.2.38 12.3.4.2.39 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_error_statuses_preserve_conversion_contracts.expected
*/
// What it checks:
// 1. A generic error response converts to a failed generic operation.
// 2. A address error response converts to a failed generic operation.
// 3. A command error response converts to a failed generic operation.
// 4. A burst error response converts to a failed generic operation.
// 5. A byte-enable error response converts to a failed generic operation.
// 6. Error response conversion still identifies the read operation.
// 7. Error response conversion identifies the supplied bus address.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.1.2.6 (UVM-TLM-ADAPTER-ERROR-GENERIC-STATUS) gives rule 1
//    above. Setup: A completed read payload has the selected negative error
//    status; rw starts as IS_OK. Expected: The generic status becomes
//    UVM_NOT_OK.
// 2. 1800.2-2020 19.1.2.6 (UVM-TLM-ADAPTER-ERROR-ADDRESS-STATUS) gives rule 2
//    above. Setup: A completed read payload has the selected negative error
//    status; rw starts as IS_OK. Expected: The generic status becomes
//    UVM_NOT_OK.
// 3. 1800.2-2020 19.1.2.6 (UVM-TLM-ADAPTER-ERROR-COMMAND-STATUS) gives rule 3
//    above. Setup: A completed read payload has the selected negative error
//    status; rw starts as IS_OK. Expected: The generic status becomes
//    UVM_NOT_OK.
// 4. 1800.2-2020 19.1.2.6 (UVM-TLM-ADAPTER-ERROR-BURST-STATUS) gives rule 4
//    above. Setup: A completed read payload has the selected negative error
//    status; rw starts as IS_OK. Expected: The generic status becomes
//    UVM_NOT_OK.
// 5. 1800.2-2020 19.1.2.6 (UVM-TLM-ADAPTER-ERROR-BYTE-ENABLE-STATUS) gives
//    rule 5 above. Setup: A completed read payload has the selected negative
//    error status; rw starts as IS_OK. Expected: The generic status becomes
//    UVM_NOT_OK.
// 6. 1800.2-2020 19.2.2.2.2 (UVM-TLM-ADAPTER-ERROR-READ-COMMAND) gives rule 6
//    above. Setup: The same valid read payload is reused across five negative
//    response statuses. Expected: All selected error responses convert to
//    READ.
// 7. 1800.2-2020 19.1.2.2 (UVM-TLM-ADAPTER-ERROR-ADDRESS) gives rule 7 above.
//    Setup: The same valid read payload is reused across five negative
//    response statuses. Expected: All selected responses retain address 0x500.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Uniform data/enable bytes avoid imposing numeric byte ordering.
// Failed-read data and unused upper data/mask bits are not constrained.
module test_reg_tlm_adapter_error_statuses_preserve_conversion_contracts;
  import uvm_pkg::*;
  initial begin

    uvm_reg_tlm_adapter adapter;
    uvm_reg_bus_op rw;
    uvm_tlm_gp payload;
    uvm_sequence_item item;
    byte unsigned data_bytes[], enables[];
    uvm_tlm_response_status_e statuses[$];
    adapter = new("adapter"); payload = new("payload");
      data_bytes = new[2]; data_bytes[0] = 'h33; data_bytes[1] = 'h33;
      enables = new[2]; enables[0] = 'hff; enables[1] = 'hff;
      payload.set_read(); payload.set_address('h500); payload.set_data(data_bytes);
      payload.set_data_length(2); payload.set_streaming_width(2);
      payload.set_byte_enable(enables); payload.set_byte_enable_length(2);
      statuses.push_back(UVM_TLM_GENERIC_ERROR_RESPONSE);
      statuses.push_back(UVM_TLM_ADDRESS_ERROR_RESPONSE);
      statuses.push_back(UVM_TLM_COMMAND_ERROR_RESPONSE);
      statuses.push_back(UVM_TLM_BURST_ERROR_RESPONSE);
      statuses.push_back(UVM_TLM_BYTE_ENABLE_ERROR_RESPONSE);
      foreach (statuses[i]) begin
        rw.kind = UVM_WRITE; rw.addr = 0; rw.data = 0; rw.n_bits = 7;
        rw.byte_en = 0; rw.status = UVM_IS_OK;
        payload.set_response_status(statuses[i]); adapter.bus2reg(payload, rw);
        $display("UT: error %0d failed %0d read %0d address %0h", i,
                 rw.status == UVM_NOT_OK, rw.kind == UVM_READ, rw.addr);
      end
    $finish;
  end
endmodule
