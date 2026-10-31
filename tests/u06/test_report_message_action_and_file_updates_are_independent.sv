/*
:name: test_report_message_action_and_file_updates_are_independent
:description: message action and file setters update independent fields (IEEE 1800.2-2020 Section 6.2.4.8)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.2.4.8 6.2.4.9 6.2.4.10 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_message_action_and_file_updates_are_independent.expected
*/
// Use an actual file descriptor, compare its identity only, and close it
// after the getters are observed. The message is never executed.

module test_report_message_action_and_file_updates_are_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_message message = new;
    UVM_FILE destination;
    destination = $fopen("message.log", "w");
    if (destination == 0) $fatal(1, "file not opened");
    message.set_action(UVM_DISPLAY | UVM_LOG);
    message.set_file(destination);
    message.set_report_message(UVM_INFO, "ID", "body", UVM_LOW, "src.sv", 2, "ctx");
    $display("UT: combined_action %0d file_same %0d",
        message.get_action() == (UVM_DISPLAY | UVM_LOG),
             message.get_file() == destination);
    message.set_action(UVM_NO_ACTION);
    $display("UT: no_action %0d file_kept %0d", message.get_action() == UVM_NO_ACTION,
             message.get_file() == destination);
    message.set_file(0);
    $display("UT: file_cleared %0d action_kept %0d", message.get_file() == 0,
             message.get_action() == UVM_NO_ACTION);
    $fclose(destination);
    $finish;
  end
endmodule
