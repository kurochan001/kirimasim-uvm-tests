/*
:name: test_report_handler_direct_action_settings_follow_pair_then_id_then_severity
:description: a report handler returns the action of a severity-id pair before that of an id, and that of an id before that of a severity, when configured directly (IEEE 1800.2-2020 Section 6.4.4.2)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.4.4.2 6.4.4.1 6.3.8.1 F.2.2.2 F.2.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_handler_direct_action_settings_follow_pair_then_id_then_severity.expected
*/
// What it checks:
// An action set for a severity-id pair is returned before one set for the id
// alone, and one set for an id before one set for the severity; an action may
// be UVM_NO_ACTION or a bitwise OR of other action values.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.4.4.2 (UVM-HANDLER-DIRECT-ACTION-PRECEDENCE) gives the rule
// above, and 6.4.4.1 returns the stored action. Setup: take the handler of a
// report object with get_report_handler (6.3.8.1), set severity UVM_WARNING to
// UVM_COUNT, id ID_A to UVM_DISPLAY | UVM_LOG and the pair UVM_WARNING and ID_A
// to UVM_NO_ACTION. Expected: UVM_WARNING with ID_Z gives UVM_COUNT, UVM_INFO
// with ID_A gives UVM_DISPLAY | UVM_LOG, and UVM_WARNING with ID_A gives
// UVM_NO_ACTION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The handler is configured directly; uvm_report_object's set_report_*
// methods are not called, and no report is issued.
module test_report_handler_direct_action_settings_follow_pair_then_id_then_severity;
  import uvm_pkg::*;

  initial begin
    automatic uvm_report_object subject = new("subject");
    automatic uvm_report_handler handler = subject.get_report_handler();
    automatic uvm_action display_and_log = UVM_DISPLAY | UVM_LOG;
    handler.set_severity_action(UVM_WARNING, UVM_COUNT);
    handler.set_id_action("ID_A", display_and_log);
    handler.set_severity_id_action(UVM_WARNING, "ID_A", UVM_NO_ACTION);
    $display("UT: severity %0d id %0d pair %0d",
             handler.get_action(UVM_WARNING, "ID_Z") == UVM_COUNT,
             handler.get_action(UVM_INFO, "ID_A") == display_and_log,
             handler.get_action(UVM_WARNING, "ID_A") == UVM_NO_ACTION);
    $finish;
  end
endmodule
