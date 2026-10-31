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
