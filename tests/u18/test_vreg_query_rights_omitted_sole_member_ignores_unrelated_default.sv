/*
:name: test_vreg_query_rights_omitted_sole_member_ignores_unrelated_default
:description: An omitted rights map selects the sole implementing-memory map.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.6 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.1.2.4 6.6.2 6.6.3.2 6.6.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_rights_omitted_sole_member_ignores_unrelated_default.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// An omitted rights map selects the sole implementing-memory map.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.2.6
// (UVM-VREG-QUERY-RIGHTS-OMITTED-SOLE-MEMBER-IGNORES-UNRELATED-DEFAULT) gives
// the rule above. Setup: Keep a sole RW member map while the parent default
// maps only the peer memory. Expected: The stated identity, count, policy,
// offset or diagnostic-presence observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_rights_omitted_sole_member_ignores_unrelated_default;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new(.shared_maps(0));
    automatic query_catcher70 catcher=new();
    automatic string rights;
    m.owner.set_default_map(m.peer_map);m.owner.lock_model();
    uvm_report_cb::add(null,catcher);catcher.observing=1;
    rights=m.vr.get_rights();catcher.observing=0;uvm_report_cb::delete(null,catcher);
    $display("UT: sole_rights value %s errors %0d",rights,catcher.errors);
    $finish;
  end
endmodule
