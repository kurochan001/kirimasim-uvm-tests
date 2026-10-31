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
