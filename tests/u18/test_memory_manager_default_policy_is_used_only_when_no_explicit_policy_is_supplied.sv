/*
:name: test_memory_manager_default_policy_is_used_only_when_no_explicit_policy_is_supplied
:description: omitted request policy selects default_alloc and an explicit policy takes precedence (18.12.5.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.2 18.12.3 18.12.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_default_policy_is_used_only_when_no_explicit_policy_is_supplied.expected
*/
// What it checks:
// An omitted request policy uses default_alloc; an explicit policy takes
// precedence without replacing the default.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.12.5.2 (UVM-MEMORY-MANAGER-DEFAULT-POLICY-SELECTION) gives
// the rule above. Setup: Install a default policy selecting eight and
// explicitly pass another selecting sixteen. Expected: Regions start at 8/16,
// each policy randomizes once and the exact default handle is retained.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_manager_default_policy_is_used_only_when_no_explicit_policy_is_supplied;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class chosen_policy extends uvm_mem_mam_policy;
    uvm_reg_addr_t chosen;
    int calls = 0;
    constraint selected_start { start_offset == chosen; }
    function new(uvm_reg_addr_t value); chosen = value; endfunction
    function void pre_randomize(); calls++; endfunction
  endclass
  initial begin
    automatic uvm_mem_mam_cfg cfg = new();
    automatic uvm_mem_mam manager;
    automatic chosen_policy default_policy = new(8);
    automatic chosen_policy explicit_policy = new(16);
    automatic uvm_mem_region first, second;
    cfg.n_bytes = 4; cfg.start_offset = 8; cfg.end_offset = 31;
    cfg.mode = uvm_mem_mam::GREEDY; cfg.locality = uvm_mem_mam::BROAD;
    manager = new("manager", cfg);
    manager.default_alloc = default_policy;
    first = manager.request_region(4);
    second = manager.request_region(4, explicit_policy);
    if (first == null || second == null) $fatal(1, "policy allocation failed");
    $display("UT: starts %0d %0d calls %0d %0d default_retained %0d",
             first.get_start_offset(), second.get_start_offset(), default_policy.calls,
             explicit_policy.calls, manager.default_alloc == default_policy);
    $finish;
  end
endmodule
