/*
:name: test_vreg_dynamic_implementation_returns_a_reserved_region
:description: vreg dynamic implementation returns a reserved region (IEEE 1800.2-2020 Section 18.9.1.1.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.1.3 18.9.1.1.5 18.9.1.2.8 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.9.1.1.1 18.9.1.1.2 18.6.3.1 18.6.3.2 18.1.2.1 18.1.2.2 18.12.5.1 18.12.6.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_dynamic_implementation_returns_a_reserved_region.expected
*/
// What it checks:
// Successful dynamic implementation exposes its reserved region descriptor.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.1.3 (UVM-VREG-IMPLEMENT-REGION-DESCRIPTOR) gives the rule
// above. Setup: Implement two two-location elements at offset two. Expected:
// Exact memory/size agree and the active region spans 2..5 with length four.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A dynamic array reserves the memory locations required by its two packed
// 16-bit elements. Geometry queries do not require bus activity.

module test_vreg_dynamic_implementation_returns_a_reserved_region;
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
    ok = vr.implement(2, mem, 2);
    region = vr.get_region();
    if (region == null) $fatal(1, "missing implementation region");
    $display("UT: ok %0d memory %0d size %0d region %0d %0d %0d active %0d", ok,
             vr.get_memory() == mem, vr.get_size(), region.get_start_offset(),
             region.get_end_offset(), region.get_len(), count_regions(mem.mam));
    $finish;
  end
endmodule
