/*
:name: test_reg_tlm_adapter_bus2reg_preserves_enabled_data_pairs
:description: Convert an independently constructed successful read payload and preserve its enabled data bytes
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.2 19.2.1.2.6 19.1.2.1 19.1.2.2 19.1.2.3 19.1.2.5 19.1.2.6 12.3.4.2.9 12.3.4.2.12 12.3.4.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_bus2reg_preserves_enabled_data_pairs.expected
*/
// What it checks:
// The data and enables in a converted read agree on which bytes are valid.
//
// How the expected output follows from the standard:
// 1800.2-2020 19.2.2.2.2 (UVM-TLM-BUS2REG-ENABLED-DATA-PAIRS) converts
// the payload into the caller's operation. 12.3.4.2.12 specifies which
// payload array entries are enabled. 19.1.2.3 and 19.1.2.5 align the
// result's data bytes with their enable bits. Use four distinct bytes and
// two complementary masks. Compare the source entries identified by the
// enabled result bytes, without assuming an absolute numeric byte order.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_reg_tlm_adapter_bus2reg_preserves_enabled_data_pairs;
  import uvm_pkg::*;

  initial begin
    automatic uvm_reg_tlm_adapter adapter = new("adapter");
    automatic uvm_tlm_gp payload = new("payload");
    uvm_reg_bus_op op;
    byte unsigned input_data[];
    byte unsigned enables[];
    bit [3:0] source_entries;
    int enabled_count;

    input_data = new[4];
    input_data[0] = 8'h12;
    input_data[1] = 8'h34;
    input_data[2] = 8'ha7;
    input_data[3] = 8'hd8;
    enables = new[4];
    payload.set_read();
    payload.set_address('h320);
    payload.set_data(input_data);
    payload.set_data_length(input_data.size());
    payload.set_streaming_width(input_data.size());
    payload.set_byte_enable_length(enables.size());
    payload.set_response_status(UVM_TLM_OK_RESPONSE);

    for (int trial = 0; trial < 2; trial++) begin
      foreach (enables[i]) enables[i] = (i % 2 == trial) ? 8'hff : 8'h00;
      payload.set_byte_enable(enables);
      op.kind = UVM_WRITE;
      op.addr = 0;
      op.data = '1;
      op.n_bits = 32;
      op.byte_en = '1;
      op.status = UVM_NOT_OK;
      adapter.bus2reg(payload, op);

      source_entries = 0;
      enabled_count = 0;
      for (int lane = 0; lane < 4; lane++) begin
        if (op.byte_en[lane]) begin
          enabled_count++;
          foreach (input_data[i])
            if (op.data[8 * lane +: 8] == input_data[i]) source_entries[i] = 1;
        end
      end
      $display("UT: trial %0d read %0d address %0h ok %0d enabled %0d sources %04b",
               trial, op.kind == UVM_READ, op.addr, op.status == UVM_IS_OK,
               enabled_count, source_entries);
    end
    $finish;
  end
endmodule
