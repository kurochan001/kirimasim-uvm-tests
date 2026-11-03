/*
:name: test_memory_policy_in_use_contains_exact_allocated_region_handles
:description: allocation policy receives existing allocated regions as a queue of exact handles (18.12.8.2.5)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.8.2.5 18.12.8 18.12.5.2 18.12.5.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_policy_in_use_contains_exact_allocated_region_handles.expected
*/
module test_memory_policy_in_use_contains_exact_allocated_region_handles;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  // Compare membership without prescribing the manager iteration order.
  class observing_policy extends uvm_mem_mam_policy;
    uvm_mem_region first, second;
    int observed_count = -1;
    bit exact_membership = 0;
    constraint selected_start { start_offset == 20; }
    function void pre_randomize();
      bit seen_first = 0;
      bit seen_second = 0;
      observed_count = in_use.size();
      foreach (in_use[i]) begin
        if (in_use[i] == first) seen_first = 1;
        if (in_use[i] == second) seen_second = 1;
      end
      exact_membership = seen_first && seen_second && observed_count == 2;
    endfunction
  endclass
  initial begin
    automatic uvm_mem_mam_cfg cfg = new();
    automatic uvm_mem_mam manager;
    automatic observing_policy policy = new();
    automatic uvm_mem_region region;
    cfg.n_bytes = 4; cfg.start_offset = 8; cfg.end_offset = 31;
    cfg.mode = uvm_mem_mam::GREEDY; cfg.locality = uvm_mem_mam::BROAD;
    manager = new("manager", cfg);
    policy.first = manager.reserve_region(8, 4);
    policy.second = manager.reserve_region(12, 8);
    if (policy.first == null || policy.second == null) $fatal(1, "reservation failed");
    region = manager.request_region(4, policy);
    if (region == null) $fatal(1, "allocation failed");
    $display("UT: existing_regions %0d exact_membership %0d new_start %0d",
             policy.observed_count, policy.exact_membership, region.get_start_offset());
    $finish;
  end
endmodule
