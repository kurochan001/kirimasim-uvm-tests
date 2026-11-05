/*
:name: test_busop_access_memory_read_little_wide64
:description: Canonical bus operations for a 64-bit memory read on a 8-byte little-endian map (IEEE 1800.2-2020 Section 19.1.2).
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.2 19.1.2.1 19.1.2.2 19.1.2.3 19.1.2.4 19.1.2.5 19.1.2.6 19.2.1.2.5 19.2.1.2.6 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.2 18.2.3.6 18.2.5.2 18.2.4.16 17.2.2.4 15.2.1.2.1 15.2.1.2.3 18.6.3.1 18.6.3.2 18.2.3.4 18.6.5.2 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_busop_access_memory_read_little_wide64.expected
:files: helpers73/busop_fixture73.svh
*/
// Numeric-word adapter observations do not pass builtin TLM-byte conversions.
// Sort completed observer rows by address; no temporal bus order is asserted.
// Read inputs are preseeded independently, without a write roundtrip.
module test_busop_access_memory_read_little_wide64;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "busop_fixture73.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block73 blk;
    uvm_mem target;
    uvm_reg_map mapping;
    word_adapter73 adapter;
    uvm_sequencer#(packet73) sequencer;
    bus_driver73 driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure();
      target = new("memory73", 4, 64, "RW", UVM_NO_COVERAGE);
      target.configure(blk);
      mapping = blk.create_map("map73", 'h100, 8, UVM_LITTLE_ENDIAN, 1);
      mapping.add_mem(target, 'h20);
      adapter = new(); adapter.provides_responses = 0;
      sequencer = new("sequencer73", this);
      driver = new("driver73", this);
      mapping.set_sequencer(sequencer, adapter);
      mapping.set_auto_predict(0);
      blk.lock_model(); blk.reset();
      driver.storage['h120] = 'ha1b2c3d4e5f60718;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      target.read(status, 0, value, UVM_FRONTDOOR, mapping);
      $display("UT: busop_access ok %0d requests %0d driver %0d", status == UVM_IS_OK,
               adapter.requests.size(), driver.calls);
      adapter.dump_requests(1);
      $display("UT: busop_read responses %0d value %0h", adapter.responses,
               value & valid_mask73(64));
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "original busop watchdog expired"); end
endmodule
