/*
:name: test_memory_manager_reconfiguration_returns_previous_config_and_preserves_regions
:description: memory manager reconfiguration returns previous config and preserves regions (IEEE 1800.2-2020 Section 18.12.4.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.4.2 18.12.5.1 18.12.7.2.1 18.12.7.2.2 18.12.4.1 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_reconfiguration_returns_previous_config_and_preserves_regions.expected
*/
// What it checks:
// Compatible reconfiguration returns the previous configuration and retains
// existing regions.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.12.4.2 (UVM-MAM-COMPATIBLE-RECONFIGURATION) gives the rule
// above. Setup: Keep the byte width and change bounds from 0..15 to 2..31
// around region 4..5. Expected: Returned bounds are 0..15, current bounds are
// 2..31 and the region stays 4..5.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A compatible new address range contains the existing allocation and preserves
// its location width. Reconfiguration returns the prior configuration.

module test_memory_manager_reconfiguration_returns_previous_config_and_preserves_regions;
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
    cfg.end_offset = 15;
    cfg.mode = uvm_mem_mam::GREEDY;
    cfg.locality = uvm_mem_mam::BROAD;
    mam = new("mam", cfg);
    a = mam.reserve_region(4, 2);
    if (a == null) $fatal(1, "reservation failed");
    replacement.n_bytes = 1;
    replacement.start_offset = 2;
    replacement.end_offset = 31;
    replacement.mode = uvm_mem_mam::GREEDY;
    replacement.locality = uvm_mem_mam::BROAD;
    previous = mam.reconfigure(replacement);
    cfg = mam.reconfigure();
    if (previous == null || cfg == null) $fatal(1, "missing configuration");
    $display("UT: previous %0d %0d current %0d %0d region %0d %0d",
             previous.start_offset, previous.end_offset, cfg.start_offset, cfg.end_offset,
             a.get_start_offset(), a.get_end_offset());
    $finish;
  end
endmodule
