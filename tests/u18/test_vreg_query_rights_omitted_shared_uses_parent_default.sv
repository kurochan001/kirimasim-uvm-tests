/*
:name: test_vreg_query_rights_omitted_shared_uses_parent_default
:description: An omitted rights map selects the parent default when the memory has several maps.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.6 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.1.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_rights_omitted_shared_uses_parent_default.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_rights_omitted_shared_uses_parent_default;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new();
    m.owner.set_default_map(m.ro_map);m.owner.lock_model();
    $display("UT: default_rights value %s",m.vr.get_rights());
    $finish;
  end
endmodule
