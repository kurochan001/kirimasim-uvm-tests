/*
:name: test_memory_manager_release_all_returns_the_entire_pool
:description: memory manager release all returns the entire pool (IEEE 1800.2-2020 Section 18.12.5.4)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.4 18.12.5.1 18.12.6.2 18.12.7.2.3 18.12.4.1 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_release_all_returns_the_entire_pool.expected
*/
// What it checks:
// Releasing all regions returns the whole managed range to the free pool.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.12.5.4 (UVM-MAM-RELEASE-ALL-REUSE) gives the rule above.
// Setup: Reserve two disjoint ranges, release all and reserve all thirty-two
// locations. Expected: Iteration is initially empty after release; the
// full-range reservation succeeds alone.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Forcibly releasing standalone regions empties the iterator and makes the full
// managed range available.

module test_memory_manager_release_all_returns_the_entire_pool;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class fixed_policy extends uvm_mem_mam_policy;
    constraint fixed_start { start_offset == 10; }
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
    automatic uvm_mem_mam_cfg cfg = new();
    automatic uvm_mem_mam_cfg replacement = new();
    automatic uvm_mem_mam_cfg previous;
    automatic uvm_mem_mam mam;
    automatic uvm_mem_region a;
    automatic uvm_mem_region b;
    automatic uvm_mem_region c;
    automatic uvm_mem_region item;
    automatic fixed_policy alloc = new();
    automatic int count = 0;
    automatic int seen_a = 0;
    automatic int seen_b = 0;
    automatic int seen_c = 0;
    cfg.n_bytes = 1;
    cfg.start_offset = 0;
    cfg.end_offset = 31;
    cfg.mode = uvm_mem_mam::GREEDY;
    cfg.locality = uvm_mem_mam::BROAD;
    mam = new("mam", cfg);
    a = mam.reserve_region(2, 3);
    b = mam.reserve_region(12, 4);
    mam.release_all_regions();
    $display("UT: empty %0d", mam.for_each(1) == null);
    c = mam.reserve_region(0, 32);
    if (c == null) $fatal(1, "full range unavailable");
    $display("UT: locations %0d active %0d", c.get_len(), count_regions(mam));
    $finish;
  end
endmodule
