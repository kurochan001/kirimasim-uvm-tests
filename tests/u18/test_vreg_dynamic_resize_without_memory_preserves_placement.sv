/*
:name: test_vreg_dynamic_resize_without_memory_preserves_placement
:description: vreg dynamic resize without memory preserves placement (IEEE 1800.2-2020 Section 18.9.1.1.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.1.3 18.9.1.2.8 18.9.1.2.11 18.9.1.2.14 18.9.1.1.1 18.9.1.1.2 18.6.3.1 18.6.3.2 18.1.2.1 18.1.2.2 18.12.5.1 18.12.6.2 18.9.1.1.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_dynamic_resize_without_memory_preserves_placement.expected
*/
// Omitting the memory argument resizes an existing dynamic array while
// retaining its memory, base offset and increment.

module test_vreg_dynamic_resize_without_memory_preserves_placement;
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

  initial begin
    automatic model_block blk = new();
    automatic uvm_mem mem = new("mem", 64, 8, "RW", UVM_NO_COVERAGE);
    automatic uvm_mem other = new("other", 64, 8, "RW", UVM_NO_COVERAGE);
    automatic uvm_vreg vr = new("vr", 16);
    automatic uvm_mem_region original;
    automatic uvm_mem_region region;
    automatic uvm_mem_region probe;
    automatic bit ok;
    blk.configure();
    mem.configure(blk);
    other.configure(blk);
    vr.configure(blk);
    ok = vr.implement(2, mem, 2, 2);
    if (!ok) $fatal(1, "initial implementation failed");
    ok = vr.implement(3);
    $display("UT: resized %0d memory %0d size %0d offset %0d increment %0d", ok,
             vr.get_memory() == mem, vr.get_size(), vr.get_offset_in_memory(0), vr.get_incr());
    $finish;
  end
endmodule
