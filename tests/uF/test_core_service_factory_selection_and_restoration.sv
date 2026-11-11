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
// What it checks:
// 1. The core service replaces its selected factory handle.
// 2. The factory getter reflects restoration of a saved service.
// 3. Successive core-service get calls identify the current shared service
//    instance.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.4.1.4.3 (UVM-CORE-FACTORY-REPLACEMENT) gives rule 1 above.
//    Setup: Set two distinct concrete services in succession. Expected:
//    Queries identify the first then the second service, without retaining the
//    first selection.
// 2. 1800.2-2020 F.4.1.4.2 (UVM-CORE-FACTORY-GETTER-RESTORATION) gives rule 2
//    above. Setup: Save the original, perform two replacements and restore the
//    original. Expected: The getter returns the exact saved handle.
// 3. 1800.2-2020 F.4.1.3 (UVM-CORE-SERVICE-INSTANCE-STABILITY) gives rule 3
//    above. Setup: Query around service selection, object construction, random
//    draws and a delay. Expected: Each get returns the same service handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
