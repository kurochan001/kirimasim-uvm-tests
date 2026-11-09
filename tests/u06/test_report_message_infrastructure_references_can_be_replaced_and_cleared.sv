/*
:name: test_report_message_infrastructure_references_can_be_replaced_and_cleared
:description: message infrastructure references retain handle identity through replacement and clearing (IEEE 1800.2-2020 Section 6.2.3.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.2.3.1 6.2.3.2 6.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_message_infrastructure_references_can_be_replaced_and_cleared.expected
*/
// What it checks:
// 1. The message reporter accessor stores and returns its specified reference.
// 2. The message handler accessor stores and returns its specified reference.
// 3. The message server accessor stores and returns its specified reference.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.2.3.1 (UVM-REPORT-MESSAGE-REPORTER) gives rule 1 above.
//    Setup: Set, replace and clear infrastructure handles without executing a
//    report. Expected: The selected reference changes while other
//    references/messages retain their handles.
// 2. 1800.2-2020 6.2.3.2 (UVM-REPORT-MESSAGE-HANDLER) gives rule 2 above.
//    Setup: Set, replace and clear infrastructure handles without executing a
//    report. Expected: The selected reference changes while other
//    references/messages retain their handles.
// 3. 1800.2-2020 6.2.3.3 (UVM-REPORT-MESSAGE-SERVER) gives rule 3 above.
//    Setup: Set, replace and clear infrastructure handles without executing a
//    report. Expected: The selected reference changes while other
//    references/messages retain their handles.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use explicit reporter, handler and concrete server objects. Replacing
// a reference changes its getter without replacing the other two references.

module test_report_message_infrastructure_references_can_be_replaced_and_cleared;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_message message = new;
    automatic uvm_report_object first_reporter = new("first_reporter");
    automatic uvm_report_object second_reporter = new("second_reporter");
    automatic uvm_report_handler first_handler = new("first_handler");
    automatic uvm_report_handler second_handler = new("second_handler");
    automatic uvm_default_report_server first_server = new;
    automatic uvm_default_report_server second_server = new;
    message.set_report_object(first_reporter);
    message.set_report_handler(first_handler);
    message.set_report_server(first_server);
    $display("UT: initial %0d %0d %0d", message.get_report_object() == first_reporter,
             message.get_report_handler() == first_handler,
                 message.get_report_server() == first_server);
    message.set_report_object(second_reporter);
    $display("UT: reporter_update %0d others_kept %0d %0d",
        message.get_report_object() == second_reporter,
             message.get_report_handler() == first_handler,
                 message.get_report_server() == first_server);
    message.set_report_handler(second_handler);
    message.set_report_server(second_server);
    $display("UT: replacements %0d %0d %0d", message.get_report_object() == second_reporter,
             message.get_report_handler() == second_handler,
                 message.get_report_server() == second_server);
    message.set_report_object(null);
    message.set_report_handler(null);
    message.set_report_server(null);
    $display("UT: cleared %0d %0d %0d", message.get_report_object() == null,
             message.get_report_handler() == null, message.get_report_server() == null);
    $finish;
  end
endmodule
