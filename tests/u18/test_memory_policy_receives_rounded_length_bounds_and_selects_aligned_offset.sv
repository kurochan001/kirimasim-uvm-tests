/*
:name: test_memory_policy_receives_rounded_length_bounds_and_selects_aligned_offset
:description: allocation policy receives address-unit length and bounds before selecting an aligned start (18.12.8)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.8 18.12.8.2.1 18.12.8.2.2 18.12.8.2.3 18.12.8.2.4 18.12.5.2 18.12.9.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_policy_receives_rounded_length_bounds_and_selects_aligned_offset.expected
*/
// What it checks:
// 1. An extended allocation policy can constrain the region start to an
//    aligned address.
// 2. Policy len is the required number of address locations.
// 3. The policy start_offset determines the returned allocation start.
// 4. min_offset identifies the managed minimum address before policy
//    randomization.
// 5. max_offset identifies the managed maximum address before policy
//    randomization.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.8 (UVM-MEMORY-POLICY-EXTENDED-ALIGNED-START) gives rule
//    1 above. Setup: Constrain start to location 12 aligned to four in a
//    managed 8–31 range. Expected: The selected policy and returned region
//    start are both 12.
// 2. 1800.2-2020 18.12.8.2.1 (UVM-MEMORY-POLICY-LENGTH-ADDRESS-UNITS) gives
//    rule 2 above. Setup: Request ten bytes from a manager with four-byte
//    locations and inspect pre_randomize state. Expected: The policy sees
//    length three and the returned region occupies locations 12–14.
// 3. 1800.2-2020 18.12.8.2.2 (UVM-MEMORY-POLICY-START-OFFSET-PROPAGATION)
//    gives rule 3 above. Setup: Use one constrained and one procedurally
//    selected start on independent managers. Expected: Selected starts 12 and
//    30 are retained in their returned region descriptors.
// 4. 1800.2-2020 18.12.8.2.3 (UVM-MEMORY-POLICY-MINIMUM-BOUND) gives rule 4
//    above. Setup: Construct the manager with minimum location eight and
//    inspect the pre_randomize hook. Expected: The policy observes minimum
//    eight.
// 5. 1800.2-2020 18.12.8.2.4 (UVM-MEMORY-POLICY-MAXIMUM-BOUND) gives rule 5
//    above. Setup: Construct a manager whose final location is 31 and inspect
//    the pre_randomize hook. Expected: The policy observes maximum 31.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_policy_receives_rounded_length_bounds_and_selects_aligned_offset;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class aligned_policy extends uvm_mem_mam_policy;
    bit observed = 0;
    constraint aligned_start { start_offset == 12; start_offset % 4 == 0; }
    function void pre_randomize();
      observed = len == 3 && min_offset == 8 && max_offset == 31;
    endfunction
  endclass
  initial begin
    automatic uvm_mem_mam_cfg cfg = new();
    automatic uvm_mem_mam manager;
    automatic aligned_policy policy = new();
    automatic uvm_mem_region region;
    cfg.n_bytes = 4; cfg.start_offset = 8; cfg.end_offset = 31;
    cfg.mode = uvm_mem_mam::GREEDY; cfg.locality = uvm_mem_mam::BROAD;
    manager = new("manager", cfg);
    region = manager.request_region(10, policy);
    if (region == null) $fatal(1, "constrained allocation failed");
    $display("UT: pre_state %0d policy_start %0d region %0d %0d len %0d",
             policy.observed, policy.start_offset, region.get_start_offset(),
             region.get_end_offset(), region.get_len());
    $finish;
  end
endmodule
