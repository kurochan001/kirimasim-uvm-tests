/*
:name: test_comparer_reporting_controls_are_per_instance
:description: changing comparer report controls leaves another comparer configuration and results unchanged (IEEE 1800.2-2020 Section 16.3.5.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.5.1 16.3.5.2 16.3.5.3 16.3.3.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_reporting_controls_are_per_instance.expected
*/
// What it checks:
// 1. The comparer message limit accessor retains its per-instance setting,
//    defaulting to 1.
// 2. The comparer verbosity accessor retains its per-instance setting,
//    defaulting to UVM_LOW.
// 3. The comparer severity accessor retains its per-instance setting,
//    defaulting to UVM_INFO.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.3.5.1 (UVM-COMPARER-MESSAGE-LIMIT-CONFIGURATION) gives
//    rule 1 above. Setup: Read defaults, configure one comparer and inspect
//    another independent instance. Expected: Updated settings belong to the
//    selected comparer while the other retains defaults.
// 2. 1800.2-2020 16.3.5.2 (UVM-COMPARER-VERBOSITY-CONFIGURATION) gives rule 2
//    above. Setup: Read defaults, configure one comparer and inspect another
//    independent instance. Expected: Updated settings belong to the selected
//    comparer while the other retains defaults.
// 3. 1800.2-2020 16.3.5.3 (UVM-COMPARER-SEVERITY-CONFIGURATION) gives rule 3
//    above. Setup: Read defaults, configure one comparer and inspect another
//    independent instance. Expected: Updated settings belong to the selected
//    comparer while the other retains defaults.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A configured policy compares a mismatching scalar while a second
// policy retains its default reporting controls and empty comparison result.

module test_comparer_reporting_controls_are_per_instance;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_comparer first = new;
    automatic uvm_comparer second = new;
    bit result;
    first.set_show_max(0);
    first.set_verbosity(UVM_HIGH);
    first.set_severity(UVM_WARNING);
    result = first.compare_field_int("value", 1, 2, 32);
    $display("UT: first max %0d high %0d warning %0d result %0d count %0d", first.get_show_max(),
             first.get_verbosity() == UVM_HIGH, first.get_severity() == UVM_WARNING,
                 result, first.get_result());
    $display("UT: second max %0d low %0d info %0d count %0d", second.get_show_max(),
             second.get_verbosity() == UVM_LOW, second.get_severity() == UVM_INFO,
                 second.get_result());
    $finish;
  end
endmodule
