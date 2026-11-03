/*
:name: test_memory_policy_procedural_post_randomize_selects_the_reserved_region
:description: a policy can select the allocation start procedurally in post_randomize (18.12.8)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.8 18.12.5.2 18.12.8.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_policy_procedural_post_randomize_selects_the_reserved_region.expected
*/
module test_memory_policy_procedural_post_randomize_selects_the_reserved_region;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class procedural_policy extends uvm_mem_mam_policy;
    int before_calls = 0;
    int after_calls = 0;
    constraint initial_start { start_offset == 8; }
    function void pre_randomize(); before_calls++; endfunction
    function void post_randomize();
      after_calls++; start_offset = max_offset - len + 1;
    endfunction
  endclass
  initial begin
    automatic uvm_mem_mam_cfg cfg = new();
    automatic uvm_mem_mam manager;
    automatic procedural_policy policy = new();
    automatic uvm_mem_region region;
    cfg.n_bytes = 4; cfg.start_offset = 8; cfg.end_offset = 31;
    cfg.mode = uvm_mem_mam::GREEDY; cfg.locality = uvm_mem_mam::BROAD;
    manager = new("manager", cfg);
    region = manager.request_region(8, policy);
    if (region == null) $fatal(1, "procedural allocation failed");
    $display("UT: callbacks %0d %0d policy_start %0d region %0d %0d",
             policy.before_calls, policy.after_calls, policy.start_offset,
             region.get_start_offset(), region.get_end_offset());
    $finish;
  end
endmodule
