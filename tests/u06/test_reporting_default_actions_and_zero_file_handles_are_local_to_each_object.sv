/*
:name: test_reporting_default_actions_and_zero_file_handles_are_local_to_each_object
:description: reporting default actions and zero file handles are local to each object
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3 6.3.5.1 6.3.5.2 6.3.6.1 6.3.6.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reporting_default_actions_and_zero_file_handles_are_local_to_each_object.expected
*/
module test_reporting_default_actions_and_zero_file_handles_are_local_to_each_object;
  import uvm_pkg::*;
  initial begin
    automatic uvm_report_object first = new("first");
    automatic uvm_report_object peer = new("peer");
    $display("UT: default_actions info %0d warning %0d error %0d fatal %0d",
             first.get_report_action(UVM_INFO, "unused") == UVM_DISPLAY,
             first.get_report_action(UVM_WARNING, "unused") == UVM_DISPLAY,
             first.get_report_action(UVM_ERROR, "unused") == (UVM_DISPLAY | UVM_COUNT),
             first.get_report_action(UVM_FATAL, "unused") == (UVM_DISPLAY | UVM_EXIT));
    $display("UT: default_files info %0d warning %0d error %0d fatal %0d",
             first.get_report_file_handle(UVM_INFO, "unused") == 0,
             first.get_report_file_handle(UVM_WARNING, "unused") == 0,
             first.get_report_file_handle(UVM_ERROR, "unused") == 0,
             first.get_report_file_handle(UVM_FATAL, "unused") == 0);
    first.set_report_severity_action(UVM_WARNING, UVM_NO_ACTION);
    $display("UT: defaults_isolated selected %0d peer %0d other %0d",
             first.get_report_action(UVM_WARNING, "unused") == UVM_NO_ACTION,
             peer.get_report_action(UVM_WARNING, "unused") == UVM_DISPLAY,
             first.get_report_action(UVM_INFO, "unused") == UVM_DISPLAY);
    $finish;
  end
endmodule
