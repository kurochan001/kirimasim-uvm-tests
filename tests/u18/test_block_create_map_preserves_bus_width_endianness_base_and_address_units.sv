/*
:name: test_block_create_map_preserves_bus_width_endianness_base_and_address_units
:description: create_map configures explicit word addressing and omitted byte addressing (18.1.2.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.2.3 18.2.4.2 18.2.4.4 18.2.4.5 18.2.4.6 18.2.4.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_create_map_preserves_bus_width_endianness_base_and_address_units.expected
*/
// What it checks:
// 1. create_map preserves its configured name, parent, base address, bus width
//    and endianness.
// 2. Omitted byte_addressing uses byte units while explicit zero uses bus-word
//    units.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.2.3 (UVM-BLOCK-CREATE-MAP-CONFIGURATION) gives rule 1
//    above. Setup: Create explicit word-addressed big-endian and
//    default-byte-addressed little-endian maps with width four. Expected:
//    Names/parents are exact, bases are 256/512, widths are four and the
//    configured endian values match.
// 2. 1800.2-2020 18.1.2.3 (UVM-BLOCK-CREATE-MAP-ADDRESSING-UNITS) gives rule 2
//    above. Setup: Compare two maps with four-byte bus widths. Expected:
//    Smallest addressable units are four for words and one for the omitted
//    byte setting.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_block_create_map_preserves_bus_width_endianness_base_and_address_units;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class reg_type extends uvm_reg;
    function new(string name); super.new(name, 8, UVM_NO_COVERAGE); endfunction
  endclass
  function automatic reg_type add_reg(block_type owner, uvm_reg_map map_value,
                                     string name, uvm_reg_addr_t offset);
    reg_type value = new(name);
    uvm_reg_field field_value = new("value");
    value.configure(owner);
    field_value.configure(value, 8, 0, "RW", 0, 0, 1, 0, 1);
    map_value.add_reg(value, offset, "RW");
    return value;
  endfunction
  initial begin
    automatic block_type owner = new("owner");
    automatic uvm_reg_map words, bytes_map;
    owner.configure();
    words = owner.create_map("words", 256, 4, UVM_BIG_ENDIAN, 0);
    bytes_map = owner.create_map("bytes", 512, 4, UVM_LITTLE_ENDIAN);
    $display("UT: word parent %0d name %s base %0d width %0d big_endian %0d unit %0d",
             words.get_parent() == owner, words.get_name(), words.get_base_addr(UVM_NO_HIER),
             words.get_n_bytes(UVM_NO_HIER), words.get_endian(UVM_NO_HIER) == UVM_BIG_ENDIAN,
             words.get_addr_unit_bytes());
    $display("UT: byte parent %0d name %s base %0d width %0d little_endian %0d unit %0d",
             bytes_map.get_parent() == owner, bytes_map.get_name(),
             bytes_map.get_base_addr(UVM_NO_HIER), bytes_map.get_n_bytes(UVM_NO_HIER),
             bytes_map.get_endian(UVM_NO_HIER) == UVM_LITTLE_ENDIAN,
             bytes_map.get_addr_unit_bytes());
    $finish;
  end
endmodule
