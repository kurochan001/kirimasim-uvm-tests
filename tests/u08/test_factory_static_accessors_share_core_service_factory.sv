/*
:name: test_factory_static_accessors_share_core_service_factory
:description: factory static accessors and core-service accessors share the selected factory (IEEE 1800.2-2020 Section 8.3.1.2.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.2.1 8.3.1.2.2 F.4.1.4.2 F.4.1.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_static_accessors_share_core_service_factory.expected
*/
// Replace the service through both API paths and restore the saved
// factory handle. Observe identity rather than implementation internals.

module test_factory_static_accessors_share_core_service_factory;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_coreservice_t service = uvm_coreservice_t::get();
    automatic uvm_factory saved = service.get_factory();
    automatic uvm_default_factory first = new;
    automatic uvm_default_factory second = new;
    service.set_factory(first);
    $display("UT: core_to_static %0d", uvm_factory::get() == first);
    uvm_factory::set(second);
    $display("UT: static_to_core %0d", service.get_factory() == second);
    uvm_factory::set(saved);
    $display("UT: restored %0d %0d", uvm_factory::get() == saved, service.get_factory() == saved);
    $finish;
  end
endmodule
