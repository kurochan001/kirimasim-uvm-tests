/*
:name: test_mam_stale_vreg_allocate_release_114
:description: stale memory-manager descriptor is rejected for a virtual-register allocation region after virtual-register release (IEEE 1800.2-2020 Section 18.12.5.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.3 18.9.1.1.6 18.9.1.1.4 18.12.5.2 18.12.8.2.2 18.9.1.1.5 18.9.1.1.1 18.9.1.1.2 18.12.7.2.7 18.6.2 18.6.3.1 18.6.3.2 18.1.2.1 18.1.2.2 18.12.5.1 18.12.4.1 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 6.6.5 D.4.4 1800-2023 6.21 8.20 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_stale_vreg_allocate_release_114.expected
:files: helpers114_mam_stale_source/stale_source114.svh
*/
// What it checks:
// 1. After a dynamic virtual-register release, releasing the saved
//    implementation descriptor through the memory's manager reports an error.
// 2. The virtual-register release returns only the implementing region to the
//    memory's manager, leaving an independent peer reservation allocated and
//    the array unimplemented.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.5.3 (UVM-VREG-AUDIT-STALE-REGION-MANAGER-RELEASE-ERROR)
//    gives rule 1 above. Setup: In a 64-location eight-bit memory, reserve a
//    four-byte peer at location 40 through the memory's manager. Implement two
//    sixteen-bit elements at offset two, or allocate three elements through
//    that manager with a policy constrained to start at ten, and save the
//    region returned by the getter or by the allocation. Release the array
//    with the virtual-register release method, reserve and release the freed
//    range again, then release the saved descriptor through the manager.
//    Expected: The release of the stale implementation descriptor reports an
//    error.
// 2. 1800.2-2020 18.9.1.1.6 (UVM-VREG-AUDIT-RELEASE-KEEPS-PEER-RESERVATION)
//    gives rule 2 above. Setup: In a 64-location eight-bit memory, reserve a
//    four-byte peer at location 40 through the memory's manager. Implement two
//    sixteen-bit elements at offset two, or allocate three elements through
//    that manager with a policy constrained to start at ten, and save the
//    region returned by the getter or by the allocation. Release the array
//    with the virtual-register release method, then reserve and release the
//    freed range using the saved start, end and byte count. Expected: Only the
//    peer remains allocated, the region getter returns null, and the freed
//    range can be reserved with its saved geometry and released again.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The region returned by a virtual-register allocation, released by uvm_vreg,
// is no longer allocated, so releasing it through the manager again reports an
// error. A peer reservation stays allocated. All membership and reuse checks
// precede the invalid release; later checks use an independently constructed
// manager, without rollback assumptions. Only the presence of an error is
// checked. The DIAG114 error count and region-owner rows are diagnostic; the
// existing virtual-owner test asserts that query.
module test_mam_stale_vreg_allocate_release_114;
  import uvm_pkg::*;
  localparam int SOURCE114=3;
  `include "stale_source114.svh"
  initial begin exercise114(); $finish; end
endmodule
