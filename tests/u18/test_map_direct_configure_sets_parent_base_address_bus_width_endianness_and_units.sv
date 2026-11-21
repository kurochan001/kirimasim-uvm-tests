/*
:name: test_map_direct_configure_sets_parent_base_address_bus_width_endianness_and_units
:description: configure called on an address map sets its parent block, base address, bus width, endianness and address unit (IEEE 1800.2-2020 Section 18.2.3.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.2 18.2.3.1 18.2.4.2 18.2.4.4 18.2.4.5 18.2.4.6 18.2.4.7 17.2.2.4 1800-2023 6.21 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_direct_configure_sets_parent_base_address_bus_width_endianness_and_units.expected
*/
// What it checks:
// configure, called on a map that the test constructs itself, sets the parent
// block, the base address, the bus width in bytes, the endianness and whether
// addresses count bytes or words.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.2.3.2 (UVM-MAP-DIRECT-CONFIGURE) gives the rule above. Setup:
// construct two maps with new (18.2.3.1) and configure them on one block: the
// first at base 'h1000 with 4 bytes, UVM_BIG_ENDIAN and the default byte
// addressing, the second at base 'h20 with 2 bytes, UVM_LITTLE_ENDIAN and word
// addressing. Expected: each map returns its block from get_parent (18.2.4.2),
// its base from get_base_addr (18.2.4.4, a root map), its own width from
// get_n_bytes with UVM_NO_HIER (18.2.4.5), which leaves out the effective
// width toward the system level, and its endianness from get_endian
// (18.2.4.7); by
// 18.2.4.6 the address unit is 1 byte for the first map and its 2 bytes for
// the second.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// uvm_reg_block::create_map is not called, so the block's own list of maps is
// not part of this test.
module test_map_direct_configure_sets_parent_base_address_bus_width_endianness_and_units;
  import uvm_pkg::*;

  class plain_block extends uvm_reg_block;
    function new(string name="plain_block");
      super.new(name);
    endfunction
  endclass

  initial begin
    automatic plain_block block = new("block");
    automatic uvm_reg_map byte_map = new("byte_map");
    automatic uvm_reg_map word_map = new("word_map");
    byte_map.configure(block, 'h1000, 4, UVM_BIG_ENDIAN);
    word_map.configure(block, 'h20, 2, UVM_LITTLE_ENDIAN, 0);
    $display("UT: byte_map parent %0d base %0h bytes %0d big %0d unit %0d",
             byte_map.get_parent() == block, byte_map.get_base_addr(),
             byte_map.get_n_bytes(UVM_NO_HIER),
             byte_map.get_endian() == UVM_BIG_ENDIAN, byte_map.get_addr_unit_bytes());
    $display("UT: word_map parent %0d base %0h bytes %0d little %0d unit %0d",
             word_map.get_parent() == block, word_map.get_base_addr(),
             word_map.get_n_bytes(UVM_NO_HIER),
             word_map.get_endian() == UVM_LITTLE_ENDIAN, word_map.get_addr_unit_bytes());
    $finish;
  end
endmodule
