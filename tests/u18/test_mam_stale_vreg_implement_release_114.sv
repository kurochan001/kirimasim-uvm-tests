/*
:name: test_mam_stale_vreg_implement_release_114
:description: stale memory-manager descriptor is rejected for a virtual-register implementation region after virtual-register release (IEEE 1800.2-2020 Section 18.12.5.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.3 18.9.1.1.6 18.9.1.1.3 18.9.1.1.5 18.9.1.1.1 18.9.1.1.2 18.12.7.2.7 18.6.2 18.6.3.1 18.6.3.2 18.1.2.1 18.1.2.2 18.12.5.1 18.12.4.1 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 6.6.5 D.4.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_stale_vreg_implement_release_114.expected
:files: helpers114_mam_stale_source/stale_source114.svh
*/
// The region of an implemented virtual-register array, released by uvm_vreg, is
// no longer allocated, so releasing it through the manager again reports an
// error. A peer reservation stays allocated. All membership and reuse checks
// precede the invalid release; later checks use an independently constructed
// manager, without rollback assumptions. Only the presence of an error is
// checked. The DIAG114 error count and region-owner rows are diagnostic; the
// existing virtual-owner test asserts that query.
module test_mam_stale_vreg_implement_release_114;
  import uvm_pkg::*;
  localparam int SOURCE114=2;
  `include "stale_source114.svh"
  initial begin exercise114(); $finish; end
endmodule
