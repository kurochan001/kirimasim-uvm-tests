/*
:name: test_mam_stale_request_region_release_114
:description: stale memory-manager descriptor is rejected for a requested descriptor released through its region facade (IEEE 1800.2-2020 Section 18.12.5.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.3 18.12.5.2 18.12.7.2.5 18.12.8.2.2 18.12.5.1 18.12.4.1 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 6.6.5 D.4.4 1800-2023 6.21 8.20 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_stale_request_region_release_114.expected
:files: helpers114_mam_stale_source/stale_source114.svh
*/
// What it checks:
// 1. The region release method returns its own range to the manager without
//    releasing an independent peer.
// 2. Releasing, through the manager, a requested descriptor that is no longer
//    allocated after a manager or region-facade release reports an error.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.7.2.5 (UVM-MAM-AUDIT-REGION-RELEASE) gives rule 1
//    above. Setup: Use the linked original fixtures and the explicit sizes,
//    location offsets, handles and observations they declare. Allocation
//    inputs are configured explicitly rather than relying on unspecified
//    initial defaults. Expected: The region release method returns its own
//    range to the manager without releasing an independent peer.
// 2. 1800.2-2020 18.12.5.3
//    (UVM-MAM-AUDIT-STALE-REQUEST-DESCRIPTOR-RELEASE-ERROR) gives rule 2
//    above. Setup: In a 32-location manager, reserve locations 0 to 3 as a
//    peer and request four locations with a policy constrained to start at 12.
//    Release the requested descriptor through the manager or through its
//    region facade, reserve and release the freed range again, then release
//    the saved descriptor through the manager. Expected: The release of the
//    stale requested descriptor reports an error.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A request_region descriptor released through its region facade is no longer
// allocated, so releasing it through the manager again reports an error. A peer
// reservation stays allocated. All membership and reuse checks precede the
// invalid release; later checks use an independently constructed manager,
// without rollback assumptions. Only the presence of an error is checked; the
// DIAG114 count is diagnostic.
module test_mam_stale_request_region_release_114;
  import uvm_pkg::*;
  localparam int SOURCE114=1;
  `include "stale_source114.svh"
  initial begin exercise114(); $finish; end
endmodule
