/*
:name: test_vreg_query_map_membership_selected_and_unrelated
:description: Map membership distinguishes an implementing-memory map from an unrelated map.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.4 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_map_membership_selected_and_unrelated.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// Map membership distinguishes an implementing-memory map from an unrelated
// map.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.2.4
// (UVM-VREG-QUERY-MAP-MEMBERSHIP-SELECTED-AND-UNRELATED) gives the rule above.
// Setup: Use shared memory maps and a sibling map containing only the peer
// memory. Expected: The stated identity, count, policy, offset or
// diagnostic-presence observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_map_membership_selected_and_unrelated;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new();
    m.owner.lock_model();
    $display("UT: map_membership selected %0d unrelated %0d",
      m.vr.is_in_map(m.ro_map),m.vr.is_in_map(m.peer_map));
    $finish;
  end
endmodule
