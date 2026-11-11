/*
:name: test_vreg_query_field_access_explicit_ro
:description: The virtual-field access query includes explicit shared-map RO restrictions.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.3.4 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.10.2.1 18.10.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_field_access_explicit_ro.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// The virtual-field access query includes explicit shared-map RO restrictions.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.10.3.4 (UVM-VREG-QUERY-FIELD-ACCESS-EXPLICIT-RO) gives the
// rule above. Setup: Use read-write memory shared by RW, RO and WO sibling
// maps and explicitly select the query map. Expected: The stated identity,
// count, policy, offset or diagnostic-presence observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_field_access_explicit_ro;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new();
    automatic uvm_vreg_field field=uvm_vreg_field::type_id::create("field70");
    field.configure(m.vr,11,7);m.owner.lock_model();
    $display("UT: field_access_RO value %s",field.get_access(m.ro_map));
    $finish;
  end
endmodule
