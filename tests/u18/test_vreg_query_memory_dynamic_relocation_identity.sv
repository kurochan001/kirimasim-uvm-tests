/*
:name: test_vreg_query_memory_dynamic_relocation_identity
:description: The memory getter follows a successful explicit dynamic relocation.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.9.1.1.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_memory_dynamic_relocation_identity.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// The memory getter follows a successful explicit dynamic relocation.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.2.2 (UVM-VREG-QUERY-MEMORY-DYNAMIC-RELOCATION-IDENTITY)
// gives the rule above. Setup: Relocate to a free range of an explicit peer in
// the same parent block. Expected: The stated identity, count, policy, offset
// or diagnostic-presence observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_memory_dynamic_relocation_identity;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new(.dynamic_mode(1));
    automatic bit relocated;
    m.owner.lock_model();relocated=m.vr.implement(4,m.peer,12,5);
    if(!relocated)$fatal(1,"relocation setup70 failed");
    $display("UT: relocated_memory selected %0d old %0d",
      m.vr.get_memory()==m.peer,m.vr.get_memory()==m.mem);
    $finish;
  end
endmodule
