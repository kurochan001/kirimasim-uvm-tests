/*
:name: test_mem_location_offsets_include_the_location_index_stride
:description: memory local offsets and external addresses include the selected location (IEEE 1800.2-2020 Section 18.6.4.15)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.15 18.6.4.16 18.6.3.2 18.1.2.3 18.2.3.4 18.1.2.6 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_location_offsets_include_the_location_index_stride.expected
*/
// What it checks:
// A memory location offset reflects the selected location index within its
// map.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.6.4.15 (UVM-MEMORY-LOCATION-OFFSET) gives the rule above.
// Setup: A 16-bit memory starts at offset 0x20 on a byte-addressed map with
// base 0x100. Retain that original case,and additionally use locked shared
// 16/64-bit memories in flat byte/word maps with nonzero root bases and
// completed selected-map/peer relocation and restoration;observe locations
// 0,1,and the last configured index. Expected: Selected locations yield
// offsets 0x20, 0x22, 0x26 and addresses 0x120, 0x122, 0x126. In the
// additional profiles,each local location offset equals its current map start
// plus index times the integral location stride in that map's units;external
// addresses add the declared root base. Original and new expectations remain
// when a combination differs.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A two-byte location advances both local offset and external address by
// two bytes. The location argument is retained in the standard get_offset API.

module test_mem_location_offsets_include_the_location_index_stride;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=8);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass
  class model_mem extends uvm_mem;
    function new(string name="mem", longint unsigned size=4,
                 int unsigned width=16, string access="RW");
      super.new(name, size, width, access, UVM_NO_COVERAGE);
    endfunction
  endclass

  initial begin
    automatic model_block blk = new("blk");
    automatic model_mem mem = new("mem", 4, 16);
    uvm_reg_map mapping;

    blk.configure();
    mem.configure(blk);
    mapping = blk.create_map("bus", 'h100, 2, UVM_LITTLE_ENDIAN);
    mapping.add_mem(mem, 'h20);
    blk.lock_model();
    $display("UT: offsets %0h %0h %0h", mem.get_offset(0, mapping),
             mem.get_offset(1, mapping), mem.get_offset(3, mapping));
    $display("UT: addresses %0h %0h %0h", mem.get_address(0, mapping),
             mem.get_address(1, mapping), mem.get_address(3, mapping));
    $finish;
  end
endmodule
