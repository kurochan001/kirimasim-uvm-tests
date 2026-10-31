/*
:name: test_reg_tlm_adapter_allocates_distinct_payloads_for_successive_operations
:description: successive reg2bus calls allocate distinct independently stored payloads (IEEE 1800.2-2020 Section 19.2.2.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.1 19.2.1.2.5 19.1.2 12.3.4.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_allocates_distinct_payloads_for_successive_operations.expected
*/
// Allocation is observed by handle identity and independent address state.

module test_reg_tlm_adapter_allocates_distinct_payloads_for_successive_operations;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_reg_tlm_adapter adapter = new("adapter");
    automatic uvm_reg_bus_op op;
    uvm_sequence_item item;
    uvm_tlm_gp payload;
    uvm_tlm_gp second;
    op.kind = UVM_WRITE;
    op.addr = 'h120;
    op.data = 'ha5a5;
    op.n_bits = 16;
    op.byte_en = '1;
    op.status = UVM_IS_OK;
    item = adapter.reg2bus(op);
    if (!$cast(payload, item)) $fatal(1, "adapter returned wrong payload type");
    op.addr = 'h280;
    item = adapter.reg2bus(op);
    if (!$cast(second, item)) $fatal(1, "adapter returned wrong payload type");
    payload.set_address('h400);
    $display("UT: distinct %0d first %0h second %0h", payload != second,
             payload.get_address(), second.get_address());
    $finish;
  end
endmodule
