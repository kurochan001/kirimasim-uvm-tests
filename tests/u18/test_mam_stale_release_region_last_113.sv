/*
:name: test_mam_stale_release_region_last_113
:description: stale memory-manager descriptor is rejected after region-facade release, last handle (IEEE 1800.2-2020 Section 18.12.5.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.3 18.12.7.2.5 18.12.5.1 18.12.4.1 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 6.6.5 D.4.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_stale_release_region_last_113.expected
:files: helpers113_mam_stale/stale_release113.svh
*/
// What it checks:
// 1. The region release method returns its own range to the manager without
//    releasing an independent peer.
// 2. Releasing, through the manager, a descriptor that is no longer allocated
//    after a release of all regions or a region-facade release reports an
//    error.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.7.2.5 (UVM-MAM-AUDIT-REGION-RELEASE) gives rule 1
//    above. Setup: Use the linked original fixtures and the explicit sizes,
//    location offsets, handles and observations they declare. Allocation
//    inputs are configured explicitly rather than relying on unspecified
//    initial defaults. Expected: The region release method returns its own
//    range to the manager without releasing an independent peer.
// 2. 1800.2-2020 18.12.5.3 (UVM-MAM-AUDIT-STALE-DESCRIPTOR-RELEASE-ERROR)
//    gives rule 2 above. Setup: Reserve three four-location regions at
//    locations 4, 12 and 20 of a 32-location manager, release all of them or
//    the first or last allocated one through its region facade, reserve and
//    release the freed range again, then release the saved first or last
//    descriptor through the manager. Each of two rounds uses a fresh manager.
//    Expected: Each release of the stale descriptor reports an error.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A descriptor released by region-facade release is no longer allocated, so
// releasing it through the manager again reports an error. The last
// handle refers to allocation-call order, not iterator order. All membership
// and reuse checks precede the invalid release; later checks use an
// independently constructed manager, without rollback assumptions. Only the
// presence of an error is checked; the DIAG113 count is diagnostic.
module test_mam_stale_release_region_last_113;
  import uvm_pkg::*;
  localparam bit BULK113=0;
  localparam int PICK113=2;
  `include "stale_release113.svh"
  initial begin exercise113(); $finish; end
endmodule
