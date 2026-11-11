/*
:name: test_mam_reconfigure_shrink_request_115
:description: memory-manager reconfiguration that narrows the address space governs later requests (IEEE 1800.2-2020 Section 18.12.4.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.4.2 18.12.5.2 18.12.8.2.1 18.12.8.2.2 18.12.8.2.3 18.12.8.2.4 18.12.5.1 18.12.5.3 18.12.4.1 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 18.12.9.2.4 18.12.9.2.5 1800-2023 6.21 8.20 18.5 18.6.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_reconfigure_shrink_request_115.expected
:files: helpers115_mam_reconfigure/reconfigure115.svh
*/
// What it checks:
// 1. After reconfiguration moves both address-space bounds, policy-driven
//    requests follow the new bounds.
// 2. After reconfiguration, the policy minimum offset presented to a request
//    is the new managed-space start.
// 3. After reconfiguration, the policy maximum offset presented to a request
//    is the new managed-space end.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.4.2 (UVM-MAM-AUDIT-RECONFIGURED-BOUNDS-REQUEST) gives
//    rule 1 above. Setup: In a manager with one byte per location and
//    GREEDY/BROAD configuration that holds region 12..15, reconfigure the
//    address space from 8..23 to 4..27 or from 4..27 to 8..23, keeping the
//    byte width. Then make four-location policy-driven requests at each new
//    edge and at the four locations just outside each new bound. Each request
//    uses a policy constrained to start at that location. Expected: Both edge
//    attempts succeed with exact geometry, both outside attempts return null,
//    and only the held region and the two edge regions remain allocated.
// 2. 1800.2-2020 18.12.8.2.3 (UVM-MAM-AUDIT-RECONFIGURED-POLICY-MINIMUM) gives
//    rule 2 above. Setup: In a manager with one byte per location and
//    GREEDY/BROAD configuration that holds region 12..15, reconfigure the
//    address space from 8..23 to 4..27 or from 4..27 to 8..23, keeping the
//    byte width. Then make four-location policy-driven requests at each new
//    edge and at the four locations just outside each new bound. Each request
//    uses a policy constrained to start at that location. Expected: Every
//    pre_randomize call after reconfiguration sees min_offset equal to the new
//    bound and a length of four, and the two successful edge requests make at
//    least two such calls.
// 3. 1800.2-2020 18.12.8.2.4 (UVM-MAM-AUDIT-RECONFIGURED-POLICY-MAXIMUM) gives
//    rule 3 above. Setup: In a manager with one byte per location and
//    GREEDY/BROAD configuration that holds region 12..15, reconfigure the
//    address space from 8..23 to 4..27 or from 4..27 to 8..23, keeping the
//    byte width. Then make four-location policy-driven requests at each new
//    edge and at the four locations just outside each new bound. Each request
//    uses a policy constrained to start at that location. Expected: Every
//    pre_randomize call after reconfiguration sees max_offset equal to the new
//    bound and a length of four, and the two successful edge requests make at
//    least two such calls.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Reconfiguring the manager from 4..27 to 8..23 changes the managed address
// space. Later requests at both new edges succeed with exact geometry, and the
// four locations just outside each new bound are rejected; locations 4..7 and
// 24..27 are probed before the change as a control and released. The held
// region 12..15 stays allocated. Fixed-start policies make each request
// deterministic; their pre_randomize hook records the bounds and length it
// receives.
module test_mam_reconfigure_shrink_request_115;
  import uvm_pkg::*;
  localparam bit EXPAND115=0;
  localparam bit REQUEST115=1;
  `include "reconfigure115.svh"
  initial begin exercise115(); $finish; end
endmodule
