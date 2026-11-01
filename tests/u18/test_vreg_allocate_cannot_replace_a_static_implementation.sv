/*
:name: test_vreg_allocate_cannot_replace_a_static_implementation
:description: vreg allocate cannot replace a static implementation (IEEE 1800.2-2020 Section 18.9.1.1.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.1.2 18.9.1.1.4 18.9.1.2.14 18.12.6.2 18.9.1.1.1 18.9.1.1.5 18.12.5.2 18.12.8.1 18.12.8.2.2 18.6.3.1 18.6.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_allocate_cannot_replace_a_static_implementation.expected
*/
// The statically configured array retains its implementation when a later
// dynamic allocation is attempted. No diagnostic severity is prescribed.

module test_vreg_allocate_cannot_replace_a_static_implementation;
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
    vr.configure(blk, mem, 2, 2, 2);
    blk.lock_model();
    original = vr.get_region();
    region = vr.allocate(2, mem.mam, policy);
    $display("UT: rejected %0d same_region %0d offset %0d active %0d", region == null,
             original != null && vr.get_region() == original, vr.get_offset_in_memory(0),
             count_regions(mem.mam));
    $finish;
  end
endmodule
