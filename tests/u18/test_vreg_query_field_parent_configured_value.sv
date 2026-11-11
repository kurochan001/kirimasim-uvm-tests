/*
:name: test_vreg_query_field_parent_configured_value
:description: The field parent getter identifies its configured virtual register.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.3.1 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.10.2.1 18.10.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_field_parent_configured_value.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// The field parent getter identifies its configured virtual register.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.10.3.1 (UVM-VREG-QUERY-FIELD-PARENT-CONFIGURED-VALUE) gives
// the rule above. Setup: Configure an 11-bit field at bit 17 in a 40-bit
// virtual register and retain a distinct peer. Expected: The stated identity,
// count, policy, offset or diagnostic-presence observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_field_parent_configured_value;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new();
    automatic uvm_vreg peer=new("peer_vreg70",40);
    automatic uvm_vreg_field field=uvm_vreg_field::type_id::create("field70");
    peer.configure(m.owner);field.configure(m.vr,11,17);m.owner.lock_model();
    $display("UT: field_parent value %0d",field.get_parent()==m.vr && field.get_parent()!=peer);
    $finish;
  end
endmodule
