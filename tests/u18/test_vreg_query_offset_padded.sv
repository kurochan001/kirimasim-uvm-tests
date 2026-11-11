/*
:name: test_vreg_query_offset_padded
:description: The element offset combines the base and index spacing in memory words.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.14 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_offset_padded.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// The element offset combines the base and index spacing in memory words.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.2.14 (UVM-VREG-QUERY-OFFSET-PADDED) gives the rule above.
// Setup: Use memory-word base five and configured increment 7; query elements
// zero and two. Expected: The stated identity, count, policy, offset or
// diagnostic-presence observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_offset_padded;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new(.stride(7));
    m.owner.lock_model();
    $display("UT: offset_padded first %0d third %0d",
      m.vr.get_offset_in_memory(0),m.vr.get_offset_in_memory(2));
    $finish;
  end
endmodule
