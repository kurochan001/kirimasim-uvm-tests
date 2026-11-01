/*
:name: test_vreg_allocate_reserves_whole_wide_memory_locations
:description: vreg allocate reserves whole wide memory locations (IEEE 1800.2-2020 Section 18.9.1.1.4)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.1.4 18.9.1.2.10 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 18.9.1.1.1 18.9.1.1.2 18.9.1.1.5 18.12.5.2 18.12.8.1 18.12.8.2.2 18.6.3.1 18.6.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_allocate_reserves_whole_wide_memory_locations.expected
*/
// Each 32-bit virtual element needs two 16-bit memory locations. Three elements
// reserve six locations and twelve bytes.

module test_vreg_allocate_reserves_whole_wide_memory_locations;
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
    automatic uvm_mem mem = new("mem", 64, 16, "RW", UVM_NO_COVERAGE);
    automatic uvm_mem other = new("other", 64, 16, "RW", UVM_NO_COVERAGE);
    automatic uvm_vreg vr = new("vr", 32);
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
    policy.chosen = 6;
    region = vr.allocate(3, mem.mam, policy);
    if (region == null) $fatal(1, "allocation failed");
    $display("UT: region %0d %0d locations %0d bytes %0d per_element %0d",
             region.get_start_offset(), region.get_end_offset(), region.get_len(),
             region.get_n_bytes(), vr.get_n_memlocs());
    $finish;
  end
endmodule
