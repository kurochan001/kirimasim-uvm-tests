/*
:name: test_reg_adapter_get_item_is_null_outside_translation_callback
:description: adapter operation context is absent outside the translation callback (IEEE 1800.2-2020 Section 19.2.1.2.7)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.1.2.7 19.2.2.2.1 19.2.1.2.5 19.1.2 12.3.4.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_adapter_get_item_is_null_outside_translation_callback.expected
*/
// The public context accessor is queried before and after standalone
// conversion.

module test_reg_adapter_get_item_is_null_outside_translation_callback;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_reg_tlm_adapter adapter = new("adapter");
    automatic uvm_reg_bus_op op;
    uvm_sequence_item item;
    uvm_tlm_gp payload;
    op.kind = UVM_WRITE;
    op.addr = 'h120;
    op.data = 'ha5a5;
    op.n_bits = 16;
    op.byte_en = '1;
    op.status = UVM_IS_OK;
    $display("UT: before_null %0d", adapter.get_item() == null);
    item = adapter.reg2bus(op);
    $display("UT: after_null %0d", adapter.get_item() == null);
    $finish;
  end
endmodule
