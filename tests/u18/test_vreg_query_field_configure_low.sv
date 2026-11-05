/*
:name: test_vreg_query_field_configure_low
:description: Virtual-field configuration records its parent, bit width and least-significant position.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.2.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.10.2.1 18.10.3.1 18.10.3.2 18.10.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_field_configure_low.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_field_configure_low;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new();
    automatic uvm_vreg_field field=uvm_vreg_field::type_id::create("field70");
    field.configure(m.vr,5,0);m.owner.lock_model();
    $display("UT: configured_low parent %0d",field.get_parent()==m.vr);
    $display("UT: configured_low width %0d",field.get_n_bits());
    $display("UT: configured_low lsb %0d",field.get_lsb_pos_in_register());
    $finish;
  end
endmodule
