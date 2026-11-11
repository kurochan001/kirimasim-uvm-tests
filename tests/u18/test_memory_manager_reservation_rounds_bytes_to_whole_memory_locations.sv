/*
:name: test_memory_manager_reservation_rounds_bytes_to_whole_memory_locations
:description: memory manager reservation rounds bytes to whole memory locations (IEEE 1800.2-2020 Section 18.12.5.1)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.1 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 18.12.7.2.6 18.12.7.2.7 18.12.4.1 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_reservation_rounds_bytes_to_whole_memory_locations.expected
*/
// What it checks:
// A byte-sized reservation occupies enough complete memory locations.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.12.5.1 (UVM-MAM-RESERVATION-WHOLE-LOCATIONS) gives the rule
// above. Setup: Reserve five bytes at location three with four-byte locations
// and no backing memory. Expected: The descriptor spans 3..4, length two,
// eight bytes, and null memory/owner handles.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Five bytes require two four-byte locations. A standalone manager has no
// associated memory or virtual register owner.

module test_memory_manager_reservation_rounds_bytes_to_whole_memory_locations;
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
    cfg.n_bytes = 4;
    cfg.start_offset = 0;
    cfg.end_offset = 31;
    cfg.mode = uvm_mem_mam::GREEDY;
    cfg.locality = uvm_mem_mam::BROAD;
    mam = new("mam", cfg);
    a = mam.reserve_region(3, 5);
    if (a == null) $fatal(1, "reservation failed");
    $display("UT: region %0d %0d locations %0d bytes %0d memory_null %0d owner_null %0d",
             a.get_start_offset(), a.get_end_offset(), a.get_len(), a.get_n_bytes(),
             a.get_memory() == null, a.get_virtual_registers() == null);
    $finish;
  end
endmodule
