/*
:name: test_mem_pre_read_hook_rejects_before_transfer_and_allows_a_clean_retry
:description: memory pre-read status can abort the transfer without disabling a later retry (IEEE 1800.2-2020 Section 18.6.9.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.9.3 18.6.3.1 18.6.3.2 18.6.5.1 18.6.5.2 18.2.3.2 18.2.3.4 18.2.3.6 18.1.2.1 18.1.2.2 18.1.2.3 18.1.5.3 19.1.1.2.3 19.1.1.2.4 19.1.1.2.6 19.1.1.2.9 19.4.2.1 19.4.2.2.1 19.4.2.2.2 19.4.2.3 D.4.5.1 10.7.2.3.1 10.7.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_pre_read_hook_rejects_before_transfer_and_allows_a_clean_retry.expected
*/
// What it checks:
// A non-OK status from memory pre_read aborts the operation before physical
// access.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.6.9.3 (UVM-MEMORY-PRE-READ-ABORT) gives the rule above.
// Setup: Reject one operation in the method, then disable rejection and retry.
// Expected: The failed attempt makes no transfer and preserves storage; the
// retry executes once and succeeds.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A user frontdoor supplies deterministic testbench storage. Hooks are the
// subject; no RTL protocol, HDL DPI, adapter or passive predictor is involved.
module test_mem_pre_read_hook_rejects_before_transfer_and_allows_a_clean_retry;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  string trace = "";
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_mem extends uvm_mem;
    bit enabled = 1;
    bit saw_callback_status = 0;
    function new(); super.new("mem", 8, 8, "RW", UVM_NO_COVERAGE); endfunction
    virtual task pre_read(uvm_reg_item rw);
      trace = {trace, "M"}; if (enabled) rw.set_status(UVM_NOT_OK);
    endtask
  endclass
  class storage_frontdoor extends uvm_reg_frontdoor;
    uvm_reg_data_t storage[uvm_reg_addr_t];
    int transfers = 0;
    uvm_reg_addr_t last_offset = 0;
    uvm_reg_data_t last_write = 0;
    function new(string name="frontdoor"); super.new(name); endfunction
    virtual task body();
      uvm_reg_addr_t offset_value;
      offset_value = rw_info.get_offset();
      #1;
      trace = {trace, "F"}; transfers++; last_offset = offset_value;
      if (rw_info.get_kind() == UVM_WRITE) begin
        last_write = rw_info.get_value(0);
        storage[offset_value] = last_write;
      end else rw_info.set_value(storage.exists(offset_value) ? storage[offset_value] : 0);
      rw_info.set_status(UVM_IS_OK);
    endtask
  endclass
  class watch extends uvm_reg_cbs;
    uvm_reg_map alternate_map;
    int calls = 0;
    function new(); super.new("watch"); endfunction

  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_mem mem;
    uvm_reg_map mapping;
    uvm_reg_map alternate_map;
    storage_frontdoor fd;
    storage_frontdoor alternate_fd;
    uvm_sequencer#(uvm_sequence_item) sequencer;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure(); mem = new(); mem.configure(blk);
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      fd = new();
      sequencer = new("sequencer", this);
      mapping.set_sequencer(sequencer);
      mapping.add_mem(mem, 'h20, "RW", 0, fd);

      blk.lock_model();
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      watch cb = new();
      phase.raise_objection(this);

      fd.storage[2] = 'h5a;
      mem.read(status, 2, value, UVM_FRONTDOOR, mapping);
      $display("UT: rejected %0d order %s n %0d stored %0h", status == UVM_NOT_OK,
               trace, fd.transfers, fd.storage[2]);
      mem.enabled = 0; trace = "";
      mem.read(status, 2, value, UVM_FRONTDOOR, mapping);
      $display("UT: retry ok %0d order %s n %0d offset %0d value %0h", status == UVM_IS_OK,
               trace, fd.transfers, fd.last_offset, value);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "memory callback watchdog expired"); end
endmodule
