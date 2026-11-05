/*
:name: test_vreg_query_region_unimplemented_is_null
:description: An unimplemented virtual array has no implementation region.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.1.5 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_region_unimplemented_is_null.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_region_unimplemented_is_null;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic block70 owner=new();
    automatic uvm_vreg vr=new("unimplemented70",40);
    owner.configure();vr.configure(owner);
    $display("UT: unimplemented_region null %0d",vr.get_region()==null);
    $finish;
  end
endmodule
