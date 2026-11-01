/*
:name: test_memory_manager_iteration_visits_each_region_once_without_assuming_order
:description: memory manager iteration visits each region once without assuming order (IEEE 1800.2-2020 Section 18.12.6.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.6.2 18.12.5.1 18.12.4.1 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_iteration_visits_each_region_once_without_assuming_order.expected
*/
// The iterator visits three handles once each. Reset restarts iteration, but no
// address ordering is required.

module test_memory_manager_iteration_visits_each_region_once_without_assuming_order;
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
    a = mam.reserve_region(12, 2);
    b = mam.reserve_region(2, 3);
    c = mam.reserve_region(8, 1);
    item = mam.for_each(1);
    repeat (8) begin
      if (item != null) begin
        count++;
        seen_a += item == a;
        seen_b += item == b;
        seen_c += item == c;
        item = mam.for_each();
      end
    end
    item = mam.for_each(1);
    $display("UT: count %0d visits %0d %0d %0d reset_nonnull %0d", count, seen_a,
             seen_b, seen_c, item != null);
    $finish;
  end
endmodule
