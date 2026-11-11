/*
:name: test_vreg_query_region_after_dynamic_release_is_null
:description: After dynamic release the implementation-region getter returns null.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.1.5 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.9.1.1.3 18.9.1.1.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_region_after_dynamic_release_is_null.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// After dynamic release the implementation-region getter returns null.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.1.5 (UVM-VREG-QUERY-REGION-AFTER-DYNAMIC-RELEASE-IS-NULL)
// gives the rule above. Setup: Release an explicitly implemented dynamic array
// using the virtual-register API. Expected: The stated identity, count,
// policy, offset or diagnostic-presence observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_region_after_dynamic_release_is_null;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new(.dynamic_mode(1));
    m.owner.lock_model();m.vr.release_region();
    $display("UT: released_region null %0d",m.vr.get_region()==null);
    $finish;
  end
endmodule
