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
// What it checks:
// 1. Message action updates retain the assigned action bits independently of
//    its file handle.
// 2. The message file accessor retains its assigned destination handle
//    independently of action updates.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.2.4.8 (UVM-REPORT-MESSAGE-ACTIONS) gives rule 1 above.
//    Setup: Set combined actions, select NO_ACTION, then clear the file
//    handle. Expected: Action queries match the selected bits and file-only
//    changes do not change them.
// 2. 1800.2-2020 6.2.4.9 (UVM-REPORT-MESSAGE-FILE) gives rule 2 above. Setup:
//    Use a real open descriptor, change actions and finally assign a null
//    descriptor. Expected: Handle identity survives action changes and the
//    final file query is cleared.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
