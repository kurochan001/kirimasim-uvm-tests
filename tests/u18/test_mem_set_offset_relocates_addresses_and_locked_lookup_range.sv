/*
:name: test_mem_set_offset_relocates_addresses_and_locked_lookup_range
:description: memory relocation changes physical addresses and the locked lookup range (IEEE 1800.2-2020 Section 18.6.3.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.3.3 18.6.4.16 18.2.4.18 18.6.3.2 18.1.2.3 18.2.3.4 18.1.2.6 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_set_offset_relocates_addresses_and_locked_lookup_range.expected
*/
// What it checks:
// Memory set_offset relocates the memory within the specified map.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.6.3.3 (UVM-MEMORY-OFFSET-RELOCATION) gives the rule above.
// Setup: Relocate a locked memory map range from offset ten to thirty.
// Expected: A queried location moves from address 12 to 32 and locked lookup
// uses the new range.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use a zero root base so map offsets and external addresses agree for
// lookup. Old addresses must stop resolving after relocation.

module test_mem_set_offset_relocates_addresses_and_locked_lookup_range;
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
    mapping = blk.create_map("bus", 0, 2, UVM_LITTLE_ENDIAN);
    mapping.add_mem(mem, 'h10);
    blk.lock_model();
    $display("UT: before %0h lookup %0d", mem.get_address(1, mapping),
             mapping.get_mem_by_offset('h12) == mem);
    mem.set_offset(mapping, 'h30);
    $display("UT: after %0h old_missing %0d new_lookup %0d", mem.get_address(1, mapping),
             mapping.get_mem_by_offset('h12) == null, mapping.get_mem_by_offset('h32) == mem);
    $finish;
  end
endmodule
