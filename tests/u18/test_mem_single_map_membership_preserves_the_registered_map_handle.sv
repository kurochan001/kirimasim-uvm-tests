/*
:name: test_mem_single_map_membership_preserves_the_registered_map_handle
:description: memory enumeration identifies its one registered map and excludes another (IEEE 1800.2-2020 Section 18.6.4.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.2 18.6.4.3 18.6.4.4 18.6.3.2 18.1.2.3 18.2.3.4 18.1.2.6 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_single_map_membership_preserves_the_registered_map_handle.expected
*/
// What it checks:
// 1. Memory map count reports the number of maps containing the memory.
// 2. Memory get_maps returns the maps where that memory is registered.
// 3. Memory is_in_map distinguishes member maps from nonmembers.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6.4.2 (UVM-MEMORY-MAP-COUNT) gives rule 1 above. Setup:
//    Register one memory in one map or two sibling-interface maps. Expected:
//    The counts are one and two for the respective fixtures.
// 2. 1800.2-2020 18.6.4.4 (UVM-MEMORY-MAP-LIST) gives rule 2 above. Setup:
//    Start with an empty map queue and inspect one/two registered maps.
//    Expected: The returned handles/list sizes agree with the registered maps.
// 3. 1800.2-2020 18.6.4.3 (UVM-MEMORY-MAP-MEMBERSHIP) gives rule 3 above.
//    Setup: Query registered maps, a different map and null in the single-map
//    fixture. Expected: Registered maps are members; the unrelated/null
//    handles are not.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Enumerate an empty queue and compare handles without ordering assumptions.

module test_mem_single_map_membership_preserves_the_registered_map_handle;
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
    uvm_reg_map other;
    uvm_reg_map maps[$];
    blk.configure();
    mem.configure(blk);
    mapping = blk.create_map("bus", 'h100, 2, UVM_LITTLE_ENDIAN);
    other = blk.create_map("unrelated", 'h400, 2, UVM_LITTLE_ENDIAN);
    mapping.add_mem(mem, 'h20);
    blk.lock_model();
    mem.get_maps(maps);
    $display("UT: count %0d listed %0d handle %0d member %0d other_member %0d null_member %0d",
             mem.get_n_maps(), maps.size(), maps.size() == 1 && maps[0] == mapping,
             mem.is_in_map(mapping), mem.is_in_map(other), mem.is_in_map(null));
    $finish;
  end
endmodule
