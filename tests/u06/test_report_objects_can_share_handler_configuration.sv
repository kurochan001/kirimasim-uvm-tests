/*
:name: test_report_objects_can_share_handler_configuration
:description: two report objects can share verbosity and action configuration through one handler (IEEE 1800.2-2020 Section 6.3.8.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.8.1 6.3.8.2 6.4.3.3 6.4.4.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_objects_can_share_handler_configuration.expected
*/
// Install one handler on two report objects. Changes through either
// object are visible through the other object using the same configured keys.

module test_report_objects_can_share_handler_configuration;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object first = new("first");
    automatic uvm_report_object second = new("second");
    automatic uvm_report_handler shared = new("shared");
    first.set_report_handler(shared);
    second.set_report_handler(shared);
    first.set_report_id_verbosity("M1_SHARED", UVM_LOW);
    second.set_report_severity_id_action(UVM_WARNING, "M1_SHARED", UVM_NO_ACTION);
    $display("UT: handlers %0d %0d", first.get_report_handler() == shared,
             second.get_report_handler() == shared);
    $display("UT: shared verbosity %0d action %0d",
             second.get_report_verbosity_level(UVM_INFO, "M1_SHARED") == UVM_LOW,
             first.get_report_action(UVM_WARNING, "M1_SHARED") == UVM_NO_ACTION);
    $finish;
  end
endmodule
