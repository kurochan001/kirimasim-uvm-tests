/*
:name: test_core_service_default_printer_replacement_and_null_fallback
:description: core service replaces the default printer and restores implementation default on null (IEEE 1800.2-2020 Section F.4.1.4.12)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.12 F.4.1.4.13 F.4.1.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_core_service_default_printer_replacement_and_null_fallback.expected
*/
// What it checks:
// 1. The core service selects each explicitly supplied default printer policy.
// 2. The default printer getter supplies an implementation default initially
//    and after a null reset.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.4.1.4.12 (UVM-CORE-DEFAULT-PRINTER-SELECTION) gives rule 1
//    above. Setup: Replace the default with two distinct concrete policy
//    instances. Expected: Each getter returns the exact most recently supplied
//    handle.
// 2. 1800.2-2020 F.4.1.4.13 (UVM-CORE-DEFAULT-PRINTER-NULL-FALLBACK) gives
//    rule 2 above. Setup: Query before any setter, select custom policies,
//    then set null. Expected: Both default queries are non-null and the
//    fallback is distinct from the two custom instances.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Check public core-service policy identity, not the default concrete type.
// A null reset must supply an implementation default, without prescribing IDs.
module test_core_service_default_printer_replacement_and_null_fallback;
  import uvm_pkg::*;

  initial begin
    automatic uvm_coreservice_t core = uvm_coreservice_t::get();
    automatic uvm_line_printer first = new("first");
    automatic uvm_line_printer second = new("second");
    uvm_printer fallback;
    $display("UT: initial available %0d", core.get_default_printer() != null);
    core.set_default_printer(first);
    $display("UT: first exact %0d", core.get_default_printer() == first);
    core.set_default_printer(second);
    $display("UT: replacement exact %0d", core.get_default_printer() == second);
    core.set_default_printer(null); fallback = core.get_default_printer();
    $display("UT: fallback available %0d excludes_custom %0d", fallback != null,
    fallback != first && fallback != second);
    $finish;
  end

endmodule
