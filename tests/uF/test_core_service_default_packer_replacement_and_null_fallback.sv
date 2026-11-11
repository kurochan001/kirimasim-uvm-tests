/*
:name: test_core_service_default_packer_replacement_and_null_fallback
:description: core service replaces the default packer and restores implementation default on null (IEEE 1800.2-2020 Section F.4.1.4.14)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.14 F.4.1.4.15 F.4.1.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_core_service_default_packer_replacement_and_null_fallback.expected
*/
// What it checks:
// 1. The core service selects each explicitly supplied default packer policy.
// 2. The default packer getter supplies an implementation default initially
//    and after a null reset.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.4.1.4.14 (UVM-CORE-DEFAULT-PACKER-SELECTION) gives rule 1
//    above. Setup: Replace the default with two distinct concrete policy
//    instances. Expected: Each getter returns the exact most recently supplied
//    handle.
// 2. 1800.2-2020 F.4.1.4.15 (UVM-CORE-DEFAULT-PACKER-NULL-FALLBACK) gives rule
//    2 above. Setup: Query before any setter, select custom policies, then set
//    null. Expected: Both default queries are non-null and the fallback is
//    distinct from the two custom instances.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Check public core-service policy identity, not the default concrete type.
// A null reset must supply an implementation default, without prescribing IDs.
module test_core_service_default_packer_replacement_and_null_fallback;
  import uvm_pkg::*;

  initial begin
    automatic uvm_coreservice_t core = uvm_coreservice_t::get();
    automatic uvm_packer first = new("first");
    automatic uvm_packer second = new("second");
    uvm_packer fallback;
    $display("UT: initial available %0d", core.get_default_packer() != null);
    core.set_default_packer(first);
    $display("UT: first exact %0d", core.get_default_packer() == first);
    core.set_default_packer(second);
    $display("UT: replacement exact %0d", core.get_default_packer() == second);
    core.set_default_packer(null); fallback = core.get_default_packer();
    $display("UT: fallback available %0d excludes_custom %0d", fallback != null,
    fallback != first && fallback != second);
    $finish;
  end

endmodule
