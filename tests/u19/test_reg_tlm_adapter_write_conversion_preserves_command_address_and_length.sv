/*
:name: test_reg_tlm_adapter_write_conversion_preserves_command_address_and_length
:description: TLM adapter write conversion preserves command address and data size (IEEE 1800.2-2020 Section 19.2.2.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.1 19.2.1.2.5 19.1.2 12.3.4.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_write_conversion_preserves_command_address_and_length.expected
*/
// Repeated data bytes avoid assuming a numeric byte serialization order.

module test_reg_tlm_adapter_write_conversion_preserves_command_address_and_length;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_reg_tlm_adapter adapter = new("adapter");
    automatic uvm_reg_bus_op op;
    uvm_sequence_item item;
    uvm_tlm_gp payload;
    byte unsigned bytes[];
    op.kind = UVM_WRITE;
    op.addr = 'h120;
    op.data = 'ha5a5;
    op.n_bits = 16;
    op.byte_en = '1;
    op.status = UVM_IS_OK;
    item = adapter.reg2bus(op);
    if (!$cast(payload, item)) $fatal(1, "adapter returned wrong payload type");
    payload.get_data(bytes);
    $display("UT: write %0d address %0h length %0d bytes %0d", payload.is_write(),
             payload.get_address(), payload.get_data_length(), bytes.size());
    if (bytes.size() == 2) $display("UT: data %0h %0h", bytes[0], bytes[1]);
    $finish;
  end
endmodule
