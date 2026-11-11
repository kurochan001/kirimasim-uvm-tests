/*
:name: test_busop_access_register_write_little_split64
:description: Canonical bus operations for a 64-bit register write on a 4-byte little-endian map (IEEE 1800.2-2020 Section 19.1.2).
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.2 19.1.2.1 19.1.2.2 19.1.2.3 19.1.2.4 19.1.2.5 19.1.2.6 19.2.1.2.5 19.2.1.2.6 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.2 18.2.3.6 18.2.5.2 18.2.4.16 17.2.2.4 15.2.1.2.1 15.2.1.2.3 18.4.2.1 18.4.2.2 18.5.3.2 18.2.3.3 18.4.4.9 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_busop_access_register_write_little_split64.expected
:files: helpers73/busop_fixture73.svh
*/
// What it checks:
// 1. Each physical bus descriptor reports the number of model bits carried by
//    that beat.
// 2. A narrower default map splits a full register or memory access into its
//    required bus operations.
// 3. Each split canonical write carries the portion of the abstract value
//    selected by its aligned bus address.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.1.2.4 (UVM-MEMORY-PARTIAL-BEAT-WIDTH) gives rule 1 above.
//    Setup: Compare adjacent 20-bit locations on an 8-bit bus with 24-bit
//    locations on a 16-bit bus. Also inspect 48/64-bit register and
//    first-memory-location reads/writes on 32/64-bit byte-addressed
//    little/big-endian buses. Expected: The logical-bit interpretation expects
//    widths 8, 8, 4 for 20 bits and byte-aligned widths 16, 8 for 24 bits,
//    preserving declared data. New full-width profiles carry 64 bits once or
//    32/32 bits; a 48-bit split carries 32/16 bits in data-significance order.
//    Observer rows are sorted by address, not execution order.
// 2. 1800.2-2020 19.1.2 (UVM-BUSOP-ACCESS-SPLIT-CYCLE-COUNT) gives rule 2
//    above. Setup: Use 48/64-bit RW objects on a 32-bit bus, no extra
//    frontdoor callbacks or auto prediction, both directions and endian modes.
//    Expected: Each selected access presents two canonical requests and two
//    driver operations with successful status.
// 3. 1800.2-2020 19.1.2 (UVM-BUSOP-ACCESS-SPLIT-WRITE-PORTIONS) gives rule 3
//    above. Setup: Use 48/64-bit register or first memory-location writes on a
//    32-bit little/big-endian bus. Expected: The address-sorted descriptors
//    retain distinct low/high value portions, ignoring unused bits above
//    n_bits.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Numeric-word adapter observations do not pass builtin TLM-byte conversions.
// Sort completed observer rows by address; no temporal bus order is asserted.
// Read inputs are preseeded independently, without a write roundtrip.
module test_busop_access_register_write_little_split64;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "busop_fixture73.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block73 blk;
    model_register73 target;
    uvm_reg_field field;
    uvm_reg_map mapping;
    word_adapter73 adapter;
    uvm_sequencer#(packet73) sequencer;
    bus_driver73 driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure();
      target = new(64); target.configure(blk);
      field = new("value73");
      field.configure(target, 64, 0, "RW", 0, 0, 1, 0, 1);
      mapping = blk.create_map("map73", 'h100, 4, UVM_LITTLE_ENDIAN, 1);
      mapping.add_reg(target, 'h20);
      adapter = new(); adapter.provides_responses = 0;
      sequencer = new("sequencer73", this);
      driver = new("driver73", this);
      mapping.set_sequencer(sequencer, adapter);
      mapping.set_auto_predict(0);
      blk.lock_model(); blk.reset();

    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      target.write(status, 'ha1b2c3d4e5f60718, UVM_FRONTDOOR, mapping);
      $display("UT: busop_access ok %0d requests %0d driver %0d", status == UVM_IS_OK,
               adapter.requests.size(), driver.calls);
      adapter.dump_requests(0);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "original busop watchdog expired"); end
endmodule
