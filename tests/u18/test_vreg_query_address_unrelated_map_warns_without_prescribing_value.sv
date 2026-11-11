/*
:name: test_vreg_query_address_unrelated_map_warns_without_prescribing_value
:description: An external-address query warns when the memory is not in the supplied map.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.15 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 6.6.2 6.6.3.2 6.6.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_address_unrelated_map_warns_without_prescribing_value.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// An external-address query warns when the memory is not in the supplied map.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.2.15
// (UVM-VREG-QUERY-ADDRESS-UNRELATED-MAP-WARNS-WITHOUT-PRESCRIBING-VALUE) gives
// the rule above. Setup: Query a sibling map containing only peer memory and
// observe WARNING during that query. Expected: The stated identity, count,
// policy, offset or diagnostic-presence observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_address_unrelated_map_warns_without_prescribing_value;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new();
    automatic query_catcher70 catcher=new();
    automatic uvm_reg_addr_t unspecified;
    m.owner.lock_model();uvm_report_cb::add(null,catcher);catcher.observing=1;
    unspecified=m.vr.get_address(2,m.peer_map);catcher.observing=0;
    uvm_report_cb::delete(null,catcher);
    $display("UT: unrelated_address warning_present %0d",catcher.warnings>0);
    $finish;
  end
endmodule
