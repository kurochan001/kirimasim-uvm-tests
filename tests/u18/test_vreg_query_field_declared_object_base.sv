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
// What it checks:
// The declared virtual field class preserves its object base view.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.10.1 (UVM-VREG-QUERY-FIELD-DECLARED-OBJECT-BASE) gives the
// rule above. Setup: Assign the actual virtual abstraction to the exact static
// base receiver. Expected: The stated identity, count, policy, offset or
// diagnostic-presence observations match.
// It also supports, as a control, the setup or conditions of
// UVM-VREG-QUERY-FIELD-OVERVIEW-LITERAL-BASE.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
