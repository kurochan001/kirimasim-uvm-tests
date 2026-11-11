/*
:name: test_vreg_query_locations_1_bits_in_8_bit_memory
:description: A virtual element uses enough complete memory locations for its bit width.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.10 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_locations_1_bits_in_8_bit_memory.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// A virtual element uses enough complete memory locations for its bit width.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.2.10 (UVM-VREG-QUERY-LOCATIONS-1-BITS-IN-8-BIT-MEMORY)
// gives the rule above. Setup: Implement 1 bits in 8-bit memory locations with
// legal element padding. Expected: The stated identity, count, policy, offset
// or diagnostic-presence observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_locations_1_bits_in_8_bit_memory;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new(.reg_bits(1),.mem_bits(8));
    m.owner.lock_model();
    $display("UT: locations_1_8 count %0d",m.vr.get_n_memlocs());
    $finish;
  end
endmodule
