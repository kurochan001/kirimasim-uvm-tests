/*
:name: test_vreg_query_address_omitted_shared_uses_parent_default
:description: An omitted address map uses the shared memory parent default map.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.15 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.1.2.4 18.2.4.6 18.6.4.16 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_address_omitted_shared_uses_parent_default.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// An omitted address map uses the shared memory parent default map.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.2.15
// (UVM-VREG-QUERY-ADDRESS-OMITTED-SHARED-USES-PARENT-DEFAULT) gives the rule
// above. Setup: Use the WO byte-addressed default with base 0x3000, memory
// offset 0x20 and element word offset 19. Expected: The stated identity,
// count, policy, offset or diagnostic-presence observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_address_omitted_shared_uses_parent_default;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new();
    m.owner.set_default_map(m.wo_map);m.owner.lock_model();
    $display("UT: default_address value %0h",m.vr.get_address(2));
    $finish;
  end
endmodule
