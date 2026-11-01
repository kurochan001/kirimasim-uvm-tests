/*
:name: test_core_service_default_copier_replacement_and_null_fallback
:description: core service replaces the default copier and restores implementation default on null (IEEE 1800.2-2020 Section F.4.1.4.18)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.18 F.4.1.4.19 F.4.1.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_core_service_default_copier_replacement_and_null_fallback.expected
*/
// Check public core-service policy identity, not the default concrete type.
// A null reset must supply an implementation default, without prescribing IDs.
module test_core_service_default_copier_replacement_and_null_fallback;
  import uvm_pkg::*;

  initial begin
    automatic uvm_coreservice_t core = uvm_coreservice_t::get();
    automatic uvm_copier first = new("first");
    automatic uvm_copier second = new("second");
    uvm_copier fallback;
    $display("UT: initial available %0d", core.get_default_copier() != null);
    core.set_default_copier(first);
    $display("UT: first exact %0d", core.get_default_copier() == first);
    core.set_default_copier(second);
    $display("UT: replacement exact %0d", core.get_default_copier() == second);
    core.set_default_copier(null); fallback = core.get_default_copier();
    $display("UT: fallback available %0d excludes_custom %0d", fallback != null,
    fallback != first && fallback != second);
    $finish;
  end

endmodule
