/*
:name: test_reg_tlm_adapter_all_enabled_and_disabled_byte_masks_are_converted
:description: adapter converts enabled and disabled byte masks into payload byte enables (IEEE 1800.2-2020 Section 19.2.2.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.1 19.2.1.2.5 19.1.2 12.3.4.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_all_enabled_and_disabled_byte_masks_are_converted.expected
*/
// What it checks:
// The TLM adapter translates enabled/disabled generic byte lanes into payload
// masks.
//
// How the expected output follows from the standard:
// 1800.2-2020 19.2.2.2.1 (UVM-TLM-ADAPTER-BYTE-MASKS) gives the rule above.
// Setup: Provide explicit generic fields or a constructed payload and inspect
// the returned conversion. Expected: All-enabled bytes become ff and
// all-disabled bytes become zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Uniform masks avoid an assumption about numeric lane ordering.

module test_reg_tlm_adapter_all_enabled_and_disabled_byte_masks_are_converted;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_reg_tlm_adapter adapter = new("adapter");
    automatic uvm_reg_bus_op op;
    uvm_sequence_item item;
    uvm_tlm_gp payload;
    byte unsigned enables[];
    op.kind = UVM_WRITE;
    op.addr = 'h120;
    op.data = 'ha5a5;
    op.n_bits = 16;
    op.byte_en = '1;
    op.status = UVM_IS_OK;
    item = adapter.reg2bus(op);
    if (!$cast(payload, item)) $fatal(1, "adapter returned wrong payload type");
    payload.get_byte_enable(enables);
    $display("UT: enabled length %0d count %0d", payload.get_byte_enable_length(), enables.size());
    if (enables.size() == 2) $display("UT: enabled %0h %0h", enables[0], enables[1]);
    op.byte_en = 0;
    item = adapter.reg2bus(op);
    if (!$cast(payload, item)) $fatal(1, "adapter returned wrong payload type");
    payload.get_byte_enable(enables);
    if (enables.size() == 2) $display("UT: disabled %0h %0h", enables[0], enables[1]);
    $finish;
  end
endmodule
