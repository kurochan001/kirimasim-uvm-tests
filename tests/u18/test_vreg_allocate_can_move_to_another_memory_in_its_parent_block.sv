/*
:name: test_vreg_allocate_can_move_to_another_memory_in_its_parent_block
:description: vreg allocate can move to another memory in its parent block (IEEE 1800.2-2020 Section 18.9.1.1.4)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.1.4 18.9.1.2.2 18.12.5.1 18.12.6.2 18.9.1.1.1 18.9.1.1.2 18.9.1.1.5 18.12.5.2 18.12.8.1 18.12.8.2.2 18.6.3.1 18.6.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_allocate_can_move_to_another_memory_in_its_parent_block.expected
*/
// What it checks:
// Dynamic allocation can move a virtual array to another memory in its parent
// block.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.1.4 (UVM-VREG-ALLOCATE-MOVE-SAME-BLOCK) gives the rule
// above. Setup: Allocate two elements in the first memory, then three in
// another. Expected: The exact new memory and size three are reported, the old
// range is available and one new region is active.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Relocation can select the manager of a second memory in the same block. The
// original memory range is returned to its manager.

module test_vreg_allocate_can_move_to_another_memory_in_its_parent_block;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass

  function automatic int count_regions(uvm_mem_mam manager);
    uvm_mem_region item = manager.for_each(1);
    int count = 0;
    while (item != null && count < 64) begin
      count++;
      item = manager.for_each();
    end
    return count;
  endfunction

  class fixed_policy extends uvm_mem_mam_policy;
    uvm_reg_addr_t chosen = 10;
    constraint fixed_start { start_offset == chosen; }
  endclass

  initial begin
    automatic model_block blk = new();
    automatic uvm_mem mem = new("mem", 64, 8, "RW", UVM_NO_COVERAGE);
    automatic uvm_mem other = new("other", 64, 8, "RW", UVM_NO_COVERAGE);
    automatic uvm_vreg vr = new("vr", 16);
    automatic fixed_policy policy = new();
    automatic uvm_mem_region region;
    automatic uvm_mem_region original;
    automatic uvm_mem_region probe;
    automatic uvm_reg_map mapping;
    blk.configure();
    mem.configure(blk);
    other.configure(blk);
    mapping = blk.create_map("bus", 'h100, 1, UVM_LITTLE_ENDIAN);
    mapping.add_mem(mem, 'h20);
    vr.configure(blk);
    blk.lock_model();
    original = vr.allocate(2, mem.mam, policy);
    if (original == null) $fatal(1, "initial allocation failed");
    region = vr.allocate(3, other.mam, policy);
    if (region == null) $fatal(1, "relocation failed");
    probe = mem.mam.reserve_region(10, 4);
    $display("UT: memory %0d size %0d old_available %0d new_active %0d",
             vr.get_memory() == other, vr.get_size(), probe != null, count_regions(other.mam));
    $finish;
  end
endmodule
