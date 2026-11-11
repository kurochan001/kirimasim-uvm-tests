/*
:name: test_mem_registered_pre_write_callback_changes_offset_and_follows_the_method_value_change
:description: memory pre-write method and callback compose value changes and redirect the written location (IEEE 1800.2-2020 Section 18.11.2.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.2.2 18.6.9.1 18.6.3.1 18.6.3.2 18.6.5.1 18.6.5.2 18.2.3.2 18.2.3.4 18.2.3.6 18.1.2.1 18.1.2.2 18.1.2.3 18.1.5.3 19.1.1.2.3 19.1.1.2.4 19.1.1.2.6 19.1.1.2.9 19.4.2.1 19.4.2.2.1 19.4.2.2.2 19.4.2.3 D.4.5.1 10.7.2.3.1 10.7.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_registered_pre_write_callback_changes_offset_and_follows_the_method_value_change.expected
*/
// What it checks:
// 1. A memory pre_write method can modify the value used by the later write.
// 2. A memory pre_write callback runs after its method and can redirect the
//    write offset.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6.9.1 (UVM-MEMORY-PRE-WRITE-VALUE) gives rule 1 above.
//    Setup: Add to the value in the method and apply a noncommuting XOR in a
//    registered callback. Expected: The frontdoor sees the composed value 3e
//    instead of the caller value 21.
// 2. 1800.2-2020 18.11.2.2 (UVM-MEMORY-PRE-WRITE-CALLBACK-OFFSET) gives rule 2
//    above. Setup: Change offset two to five in the callback after the method
//    value transform. Expected: The trace is method/callback/frontdoor and
//    only the redirected location is written.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A user frontdoor supplies deterministic testbench storage. Hooks are the
// subject; no RTL protocol, HDL DPI, adapter or passive predictor is involved.
module test_mem_registered_pre_write_callback_changes_offset_and_follows_the_method_value_change;
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
    virtual task pre_write(uvm_reg_item rw);
      trace = {trace, "M"};
      if (enabled) rw.set_value(rw.get_value(0) + 'h10);
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
    virtual task pre_write(uvm_reg_item rw);
      calls++; trace = {trace, "C"};
      rw.set_value(rw.get_value(0) ^ 'h0f); rw.set_offset(5);
    endtask
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

      fd.storage[2] = 'h22; fd.storage[5] = 'h55;
      uvm_mem_cb::add(mem, cb);
      mem.write(status, 2, 'h21, UVM_FRONTDOOR, mapping);
      $display("UT: write ok %0d order %s calls %0d n %0d offset %0d data %0h orig %0h",
               status == UVM_IS_OK, trace, cb.calls, fd.transfers, fd.last_offset, fd.last_write,
                   fd.storage[2]);
      uvm_mem_cb::delete(mem, cb); mem.enabled = 0; trace = "";
      mem.write(status, 2, 'h21, UVM_FRONTDOOR, mapping);
      $display("UT: control ok %0d order %s calls %0d n %0d offset %0d data %0h redirected %0h",
               status == UVM_IS_OK, trace, cb.calls, fd.transfers, fd.last_offset, fd.last_write,
                   fd.storage[5]);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "memory callback watchdog expired"); end
endmodule
