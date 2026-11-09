/*
:name: test_report_handler_replacement_detaches_configuration
:description: replacing one shared report handler separates subsequent configuration updates (IEEE 1800.2-2020 Section 6.3.8.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.8.1 6.3.8.2 6.3.4.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_handler_replacement_detaches_configuration.expected
*/
// What it checks:
// Setting a report handler replaces the reference and permits sharing one
// handler across report objects.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.3.8.2 (UVM-REPORT-HANDLER-SELECTION) gives the rule above.
// Setup: Share a handler, change settings, then detach one object by assigning
// another handler. Expected: Shared settings are visible to both objects until
// detachment, after which changes stay separate.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Replace the handler on one report object after sharing it. Its new
// verbosity setting does not alter the object retaining the original handler.

module test_report_handler_replacement_detaches_configuration;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object first = new("first");
    automatic uvm_report_object second = new("second");
    automatic uvm_report_handler shared = new("shared");
    automatic uvm_report_handler replacement = new("replacement");
    first.set_report_handler(shared);
    second.set_report_handler(shared);
    first.set_report_verbosity_level(UVM_LOW);
    second.set_report_handler(replacement);
    second.set_report_verbosity_level(UVM_HIGH);
    $display("UT: handlers first %0d second %0d", first.get_report_handler() == shared,
             second.get_report_handler() == replacement);
    $display("UT: independent verbosity %0d %0d",
             first.get_report_verbosity_level(UVM_INFO, "M1_SHARED") == UVM_LOW,
             second.get_report_verbosity_level(UVM_INFO, "M1_SHARED") == UVM_HIGH);
    $finish;
  end
endmodule
