/*
:name: test_memory_manager_request_region_uses_a_singleton_allocation_policy
:description: memory manager request region uses a singleton allocation policy (IEEE 1800.2-2020 Section 18.12.5.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.2 18.12.8.1 18.12.8.2.1 18.12.8.2.2 18.12.8.2.3 18.12.8.2.4 18.12.5.1 18.12.7.2.3 18.12.4.1 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_request_region_uses_a_singleton_allocation_policy.expected
*/
// What it checks:
// A region request honors a legal allocation-policy constraint.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.12.5.2 (UVM-MAM-REQUEST-SINGLETON-POLICY) gives the rule
// above. Setup: Reserve locations 0..3 and constrain a four-location request
// to start ten. Expected: Start ten, length four, policy length/bounds and two
// active regions are reported.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The policy constrains the start to location 10, making the random allocation
// deterministic at both seeds. The existing region occupies a disjoint range.

module test_memory_manager_request_region_uses_a_singleton_allocation_policy;
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
    a = mam.reserve_region(0, 4);
    b = mam.request_region(4, alloc);
    if (b == null) $fatal(1, "policy allocation failed");
    $display("UT: start %0d locations %0d policy_len %0d bounds %0d %0d active %0d",
             b.get_start_offset(), b.get_len(), alloc.len, alloc.min_offset, alloc.max_offset,
             count_regions(mam));
    $finish;
  end
endmodule
