/*
:name: test_vreg_static_implementation_cannot_be_released_dynamically
:description: vreg static implementation cannot be released dynamically (IEEE 1800.2-2020 Section 18.9.1.1.6)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.1.6 18.9.1.1.2 18.9.1.2.2 18.9.1.1.1 18.6.3.1 18.6.3.2 18.1.2.1 18.1.2.2 18.12.5.1 18.12.6.2 18.9.1.1.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_static_implementation_cannot_be_released_dynamically.expected
*/
// A static array retains its memory and reserved region when dynamic release is
// attempted. No diagnostic severity is prescribed by this case.

module test_vreg_static_implementation_cannot_be_released_dynamically;
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
    vr.configure(blk, mem, 2, 2, 2);
    original = vr.get_region();
    vr.release_region();
    $display("UT: memory %0d same_region %0d active %0d", vr.get_memory() == mem,
             original != null && vr.get_region() == original, count_regions(mem.mam));
    $finish;
  end
endmodule
