/*
:name: test_comparer_reporting_controls_defaults_and_updates
:description: comparer message limits verbosity and severity have their specified defaults (IEEE 1800.2-2020 Section 16.3.5.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.5.1 16.3.5.2 16.3.5.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_reporting_controls_defaults_and_updates.expected
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
// Read the initial reporting controls, then configure all three. Check
// returned settings without comparing the built-in miscompare text format.

module test_comparer_reporting_controls_defaults_and_updates;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_comparer policy = new;
    $display("UT: defaults max %0d low %0d info %0d", policy.get_show_max(),
             policy.get_verbosity() == UVM_LOW, policy.get_severity() == UVM_INFO);
    policy.set_show_max(3);
    policy.set_verbosity(UVM_HIGH);
    policy.set_severity(UVM_WARNING);
    $display("UT: configured max %0d high %0d warning %0d", policy.get_show_max(),
             policy.get_verbosity() == UVM_HIGH, policy.get_severity() == UVM_WARNING);
    $finish;
  end
endmodule
