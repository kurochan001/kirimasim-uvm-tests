/*
:name: test_report_message_source_setters_preserve_core_fields
:description: individual filename line and context setters preserve core message fields (IEEE 1800.2-2020 Section 6.2.4.5)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.2.4.5 6.2.4.6 6.2.4.7 6.2.4.1 6.2.4.2 6.2.4.3 6.2.4.4 6.2.4.10 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_message_source_setters_preserve_core_fields.expected
*/
// What it checks:
// 1. The message source filename accessor returns the value assigned to that
//    field.
// 2. The message source line accessor returns the value assigned to that
//    field.
// 3. The message context string accessor returns the value assigned to that
//    field.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.2.4.5 (UVM-REPORT-MESSAGE-FILENAME) gives rule 1 above.
//    Setup: Assign common fields in bulk, replace them, and exercise selected
//    individual setters. Expected: Queried values follow their assignments,
//    including cleared string/zero values where applicable.
// 2. 1800.2-2020 6.2.4.6 (UVM-REPORT-MESSAGE-LINE) gives rule 2 above. Setup:
//    Assign common fields in bulk, replace them, and exercise selected
//    individual setters. Expected: Queried values follow their assignments,
//    including cleared string/zero values where applicable.
// 3. 1800.2-2020 6.2.4.7 (UVM-REPORT-MESSAGE-CONTEXT) gives rule 3 above.
//    Setup: Assign common fields in bulk, replace them, and exercise selected
//    individual setters. Expected: Queried values follow their assignments,
//    including cleared string/zero values where applicable.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Update source metadata and clear the optional context without emitting
// a report or changing the severity, text, ID or verbosity.

module test_report_message_source_setters_preserve_core_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_message message = new;
    message.set_report_message(UVM_WARNING, "KEPT", "kept payload", UVM_MEDIUM, "old.sv",
        1, "old.ctx");
    message.set_filename("new.sv");
    message.set_line(73);
    message.set_context("new.ctx");
    $display("UT: source %s line %0d context %s", message.get_filename(),
        message.get_line(), message.get_context());
    message.set_context("");
    $display("UT: context_empty %0d warning %0d id %s text %s medium %0d",
        message.get_context() == "",
             message.get_severity() == UVM_WARNING, message.get_id(), message.get_message(),
             message.get_verbosity() == UVM_MEDIUM);
    $finish;
  end
endmodule
