/*
:name: test_package_repeated_initialization_preserves_the_selected_service_and_initialized_state
:description: Subsequent uvm_init calls do not replace the initialized service or reset selected facilities
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.1.3 F.3.1.1 F.4.1.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_repeated_initialization_preserves_the_selected_service_and_initialized_state.expected
*/
// What it checks:
// 1. Subsequent initialization calls do not reinitialize or replace the
//    selected core service.
// 2. The core-state query observes INITIALIZED after initialization without
//    running a test.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.3.1.3 (UVM-PACKAGE-AUDIT-INIT-IDEMPOTENCE) gives rule 1
//    above. Setup: Call uvm_init with omission before saving the active
//    service, allow implicit earlier initialization, then supply a new default
//    service and omission. Expected: Both calls retain the original service
//    identity; the replacement-call observation also retains root/factory
//    identity.
// 2. 1800.2-2020 F.3.1.1 (UVM-PACKAGE-AUDIT-INIT-STATE-QUERY) gives rule 2
//    above. Setup: Call uvm_init with omission before saving the active
//    service, allow implicit earlier initialization, then supply a new default
//    service and omission. Expected: Both repeated-call observations return
//    UVM_CORE_INITIALIZED.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Initial implicit initialization is allowed. Only subsequent calls are tested.
module test_package_repeated_initialization_preserves_the_selected_service_and_initialized_state;
  import uvm_pkg::*;
  initial begin
    uvm_coreservice_t original;
    uvm_default_coreservice_t replacement;
    uvm_root root;
    uvm_factory factory;
    uvm_init(); original=uvm_coreservice_t::get();
    root=original.get_root(); factory=original.get_factory();
    replacement=new(); uvm_init(replacement);
    $display("UT: repeated_init service %0d root %0d factory %0d initialized %0d",
      uvm_coreservice_t::get()==original,uvm_coreservice_t::get().get_root()==root,
      uvm_coreservice_t::get().get_factory()==factory,get_core_state()==UVM_CORE_INITIALIZED);
    uvm_init();
    $display("UT: repeated_null service %0d state %0d",uvm_coreservice_t::get()==original,
      get_core_state()==UVM_CORE_INITIALIZED);
    $finish;
  end
endmodule
