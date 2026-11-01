/*
:name: test_core_service_factory_selection_and_restoration
:description: core service selects and restores the factory (IEEE 1800.2-2020 Section F.4.1.4.3)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.3 F.4.1.4.2 F.4.1.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_core_service_factory_selection_and_restoration.expected
*/
// Swap valid concrete service instances and restore the saved handle.
// No factory creation, override execution or report-count migration is claimed.
module test_core_service_factory_selection_and_restoration;
  import uvm_pkg::*;

  initial begin
    automatic uvm_coreservice_t core = uvm_coreservice_t::get();
    automatic uvm_factory saved = core.get_factory();
    automatic uvm_default_factory first = new();
    automatic uvm_default_factory second = new();
    core.set_factory(first);
    $display("UT: selected first %0d shared_service %0d", core.get_factory() == first,
    uvm_coreservice_t::get() == core);
    core.set_factory(second);
    $display("UT: selected second %0d excludes_first %0d", core.get_factory() == second,
    core.get_factory() != first);
    core.set_factory(saved);
    $display("UT: restored exact %0d", core.get_factory() == saved);
    $finish;
  end

endmodule
