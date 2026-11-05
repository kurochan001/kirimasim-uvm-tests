/*
:name: test_vreg_query_field_access_explicit_rw
:description: The virtual-field access query includes explicit shared-map RW restrictions.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.3.4 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.10.2.1 18.10.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_field_access_explicit_rw.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_field_access_explicit_rw;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new();
    automatic uvm_vreg_field field=uvm_vreg_field::type_id::create("field70");
    field.configure(m.vr,11,7);m.owner.lock_model();
    $display("UT: field_access_RW value %s",field.get_access(m.rw_map));
    $finish;
  end
endmodule
