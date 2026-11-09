/*
:name: test_uvm_seeding_accessors_delegate_to_core_service
:description: object and core-service accessors update the same seeding enable value (IEEE 1800.2-2020 Section 5.3.3.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.3.1 5.3.3.2 F.4.1.4.25 F.4.1.4.26 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_uvm_seeding_accessors_delegate_to_core_service.expected
*/
// What it checks:
// 1. The object seeding query reads the core-service enable setting.
// 2. The object seeding setter updates the shared core-service setting.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.3.1 (UVM-SEEDING-GET) gives rule 1 above. Setup: Toggle
//    the setting through different object types and the core service.
//    Expected: Every query observes the same setting; the original setting can
//    be restored.
// 2. 1800.2-2020 5.3.3.2 (UVM-SEEDING-SET) gives rule 2 above. Setup: Set
//    through one object type and query through another API. Expected:
//    Disabling and enabling are visible across those accessors.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Set through the core service and read through the object helper, then
// reverse the direction. No observation depends on generated random values.

module test_uvm_seeding_accessors_delegate_to_core_service;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_coreservice_t service = uvm_coreservice_t::get();
    automatic bit saved = service.get_uvm_seeding();
    service.set_uvm_seeding(0);
    $display("UT: core_to_object %0d", uvm_object::get_uvm_seeding());
    uvm_object::set_uvm_seeding(1);
    $display("UT: object_to_core %0d", service.get_uvm_seeding());
    service.set_uvm_seeding(saved);
    $display("UT: restored %0d", uvm_object::get_uvm_seeding() == saved);
    $finish;
  end
endmodule
