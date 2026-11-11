/*
:name: test_vreg_query_constructor_wide
:description: Construction retains the explicit name and selected memory-rounded width.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.1.1 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.2 5.3.4.2 18.9.1.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_constructor_wide.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// 1. Construction retains the supplied virtual-register name.
// 2. Construction preserves the selected width as observed in complete
//    implementing-memory bytes.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.9.1.1.1 (UVM-VREG-QUERY-CONSTRUCTOR-NAME) gives rule 1
//    above. Setup: Construct 8 bits with an explicit name and implement it
//    over 16-bit memory locations. Construct 64 bits with an explicit name and
//    implement it over 16-bit memory locations. Expected: Only the separately
//    anchored name observation is bound to this duty.
// 2. 1800.2-2020 18.9.1.1.1 (UVM-VREG-QUERY-CONSTRUCTOR-WIDTH) gives rule 2
//    above. Setup: Construct 8 bits with an explicit name and implement it
//    over 16-bit memory locations. Construct 64 bits with an explicit name and
//    implement it over 16-bit memory locations. Expected: Only the separately
//    anchored width observation is bound to this duty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_constructor_wide;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new(.reg_bits(64),.mem_bits(16));
    automatic uvm_vreg subject=new("ctor_wide70",64);
    subject.configure(m.owner,m.peer,2,3,7);
    m.owner.lock_model();
    $display("UT: ctor_name %s",subject.get_name());
    $display("UT: ctor_width bytes %0d",subject.get_n_bytes());
    $finish;
  end
endmodule
