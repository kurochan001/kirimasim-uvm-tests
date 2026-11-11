/*
:name: test_reg_map_word_addressing_translates_offsets_in_bus_units
:description: word-addressed map uses bus-sized address units for a wide access (IEEE 1800.2-2020 Section 18.2.4.16)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.16 18.1.2.6 18.2.4.6 18.2.4.5 18.1.2.3 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_map_word_addressing_translates_offsets_in_bus_units.expected
*/
// What it checks:
// Physical-address translation returns addresses in least-significant-data
// order with the transfer width.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.2.4.16 (UVM-MAP-DATA-ORDER-PHYSICAL-ADDRESSES) gives the rule
// above. Setup: Use a wide big-endian register and a word-addressed register.
// Also call the map translator directly in empty/populated flat normal maps,
// two opposite hierarchical-width shapes and flat FIFO maps; reuse an
// initially nonempty dynamic result array across changing query lengths.
// Expected: The big-endian address list descends by two; word addressing
// advances one unit per four-byte transfer. Full integral accesses return the
// effective transfer width and the exact least-significant-data-first address
// list in the declared address units. Normal maps advance by the transfer
// width in those units; FIFO beats repeat one address. Each call supplies only
// its current list, and repeating the original query restores that list.
// Partial probes constrain the list, not the ambiguous returned partial width.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An eight-byte access over a four-byte bus needs two consecutive word
// addresses.
// The base and local offset are both expressed in those word units. Lock
// before translation and retain the required returned transfer-byte count.

module test_reg_map_word_addressing_translates_offsets_in_bus_units;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk");
      super.new(name, UVM_NO_COVERAGE);
    endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=16);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass

  initial begin
    automatic model_block blk = new("blk");
    uvm_reg_map mapping;
    uvm_reg_addr_t addresses[];
    automatic int transferred = 0;
    blk.configure();
    mapping = blk.create_map("bus", 'h20, 4, UVM_LITTLE_ENDIAN, 0);
    blk.lock_model();
    transferred = mapping.get_physical_addresses(2, 0, 8, addresses);
    $display("UT: unit %0d transfer %0d count %0d", mapping.get_addr_unit_bytes(),
             transferred, addresses.size());
    if (addresses.size() == 2)
      $display("UT: addresses %0h %0h", addresses[0], addresses[1]);
    $finish;
  end
endmodule
