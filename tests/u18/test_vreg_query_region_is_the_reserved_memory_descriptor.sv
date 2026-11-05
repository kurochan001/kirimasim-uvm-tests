/*
:name: test_vreg_query_region_is_the_reserved_memory_descriptor
:description: The region getter returns the descriptor reserving the virtual array memory.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.1.5 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.9.1.1.3 18.6.2 18.12.6.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_region_is_the_reserved_memory_descriptor.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_region_is_the_reserved_memory_descriptor;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new(.dynamic_mode(1));
    automatic uvm_mem_region returned_region;
    automatic uvm_mem_region reserved_region;
    m.owner.lock_model();
    returned_region=m.vr.get_region();reserved_region=m.mem.mam.for_each(1);
    $display("UT: implemented_region nonnull %0d reserved_identity %0d",
      returned_region!=null,returned_region==reserved_region);
    $finish;
  end
endmodule
