/*
:name: test_vreg_query_field_declared_object_base
:description: The declared virtual field class preserves its object base view.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.1 18.10.2.1 5.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_field_declared_object_base.expected
*/
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_field_declared_object_base;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
initial begin
    automatic uvm_vreg_field subject=uvm_vreg_field::type_id::create("subject70");
    automatic uvm_object base_view=subject;
    automatic uvm_object common=base_view;
    $display("UT: field_declared_object_base identity %0d",common==subject);
    $finish;
  end
endmodule
