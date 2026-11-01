/*
:name: test_memory_manager_rejects_reservations_outside_its_address_range
:description: memory manager rejects reservations outside its address range (IEEE 1800.2-2020 Section 18.12.5.1)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.1 18.12.6.2 18.12.4.1 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_rejects_reservations_outside_its_address_range.expected
*/
// A reservation cannot begin below the configured start or extend beyond the
// inclusive final location. Neither failed request reserves a region.

module test_memory_manager_rejects_reservations_outside_its_address_range;
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
    cfg.start_offset = 4;
    cfg.end_offset = 15;
    cfg.mode = uvm_mem_mam::GREEDY;
    cfg.locality = uvm_mem_mam::BROAD;
    mam = new("mam", cfg);
    a = mam.reserve_region(3, 1);
    b = mam.reserve_region(15, 2);
    $display("UT: below_rejected %0d beyond_rejected %0d active %0d", a == null,
             b == null, count_regions(mam));
    $finish;
  end
endmodule
