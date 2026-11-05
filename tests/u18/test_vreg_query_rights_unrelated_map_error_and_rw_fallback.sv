/*
:name: test_vreg_query_rights_unrelated_map_error_and_rw_fallback
:description: An unrelated rights map reports an error and returns the specified RW fallback.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.6 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 6.6.2 6.6.3.2 6.6.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_rights_unrelated_map_error_and_rw_fallback.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_rights_unrelated_map_error_and_rw_fallback;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new();
    automatic query_catcher70 catcher=new();
    automatic string rights;
    m.owner.lock_model();uvm_report_cb::add(null,catcher);catcher.observing=1;
    rights=m.vr.get_rights(m.peer_map);catcher.observing=0;
    uvm_report_cb::delete(null,catcher);
    $display("UT: unrelated_rights fallback %s",rights);
    $display("UT: unrelated_rights error_present %0d",catcher.errors>0);
    $finish;
  end
endmodule
