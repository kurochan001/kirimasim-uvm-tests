/*
:name: test_vreg_query_maps_returns_exact_shared_membership
:description: Map enumeration returns the shared implementing-memory maps.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.5 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_maps_returns_exact_shared_membership.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_maps_returns_exact_shared_membership;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new();
    automatic uvm_reg_map maps[$];
    m.owner.lock_model();m.vr.get_maps(maps);
    $display("UT: maps count %0d rw %0d ro %0d wo %0d unrelated %0d",maps.size(),
      map_count70(maps,m.rw_map),map_count70(maps,m.ro_map),
      map_count70(maps,m.wo_map),map_count70(maps,m.peer_map));
    $finish;
  end
endmodule
