/*
:name: test_report_message_core_setters_preserve_source_fields
:description: individual severity ID message and verbosity setters preserve source metadata (IEEE 1800.2-2020 Section 6.2.4.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.2.4.1 6.2.4.2 6.2.4.3 6.2.4.4 6.2.4.5 6.2.4.6 6.2.4.7 6.2.4.10 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_message_core_setters_preserve_source_fields.expected
*/
// What it checks:
// 1. The message severity accessor returns the value assigned to that field.
// 2. The message message ID accessor returns the value assigned to that field.
// 3. The message message text accessor returns the value assigned to that
//    field.
// 4. The message verbosity accessor returns the value assigned to that field.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.2.4.1 (UVM-REPORT-MESSAGE-SEVERITY) gives rule 1 above.
//    Setup: Assign common fields in bulk, replace them, and exercise selected
//    individual setters. Expected: Queried values follow their assignments,
//    including cleared string/zero values where applicable.
// 2. 1800.2-2020 6.2.4.2 (UVM-REPORT-MESSAGE-ID) gives rule 2 above. Setup:
//    Assign common fields in bulk, replace them, and exercise selected
//    individual setters. Expected: Queried values follow their assignments,
//    including cleared string/zero values where applicable.
// 3. 1800.2-2020 6.2.4.3 (UVM-REPORT-MESSAGE-TEXT) gives rule 3 above. Setup:
//    Assign common fields in bulk, replace them, and exercise selected
//    individual setters. Expected: Queried values follow their assignments,
//    including cleared string/zero values where applicable.
// 4. 1800.2-2020 6.2.4.4 (UVM-REPORT-MESSAGE-VERBOSITY) gives rule 4 above.
//    Setup: Assign common fields in bulk, replace them, and exercise selected
//    individual setters. Expected: Queried values follow their assignments,
//    including cleared string/zero values where applicable.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Update the core message fields individually while retaining the
// previously specified source location and optional context.

module test_report_message_core_setters_preserve_source_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_message message = new;
    message.set_report_message(UVM_INFO, "OLD", "old", UVM_LOW, "kept.sv", 19, "kept.ctx");
    message.set_severity(UVM_ERROR);
    message.set_id("NEW");
    message.set_message("new payload");
    message.set_verbosity(UVM_FULL);
    $display("UT: error %0d id %s text %s full %0d", message.get_severity() == UVM_ERROR,
             message.get_id(), message.get_message(), message.get_verbosity() == UVM_FULL);
    $display("UT: source %s line %0d context %s", message.get_filename(),
        message.get_line(), message.get_context());
    $finish;
  end
endmodule
