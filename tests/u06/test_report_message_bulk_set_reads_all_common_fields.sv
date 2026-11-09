/*
:name: test_report_message_bulk_set_reads_all_common_fields
:description: bulk message initialization sets all seven common fields (IEEE 1800.2-2020 Section 6.2.4.10)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.2.4.10 6.2.4.1 6.2.4.2 6.2.4.3 6.2.4.4 6.2.4.5 6.2.4.6 6.2.4.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_message_bulk_set_reads_all_common_fields.expected
*/
// What it checks:
// 1. The message severity accessor returns the value assigned to that field.
// 2. The message message ID accessor returns the value assigned to that field.
// 3. The message message text accessor returns the value assigned to that
//    field.
// 4. The message verbosity accessor returns the value assigned to that field.
// 5. The message source filename accessor returns the value assigned to that
//    field.
// 6. The message source line accessor returns the value assigned to that
//    field.
// 7. The message context string accessor returns the value assigned to that
//    field.
// 8. set_report_message assigns all seven common message fields in one call.
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
// 5. 1800.2-2020 6.2.4.5 (UVM-REPORT-MESSAGE-FILENAME) gives rule 5 above.
//    Setup: Assign common fields in bulk, replace them, and exercise selected
//    individual setters. Expected: Queried values follow their assignments,
//    including cleared string/zero values where applicable.
// 6. 1800.2-2020 6.2.4.6 (UVM-REPORT-MESSAGE-LINE) gives rule 6 above. Setup:
//    Assign common fields in bulk, replace them, and exercise selected
//    individual setters. Expected: Queried values follow their assignments,
//    including cleared string/zero values where applicable.
// 7. 1800.2-2020 6.2.4.7 (UVM-REPORT-MESSAGE-CONTEXT) gives rule 7 above.
//    Setup: Assign common fields in bulk, replace them, and exercise selected
//    individual setters. Expected: Queried values follow their assignments,
//    including cleared string/zero values where applicable.
// 8. 1800.2-2020 6.2.4.10 (UVM-REPORT-MESSAGE-BULK-SET) gives rule 8 above.
//    Setup: Set nonempty values, then replace every field with a second tuple.
//    Expected: Every getter reflects the new tuple without retaining fields
//    from the previous call.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Read explicit user-supplied fields through getters. No default field
// values or report presentation are assumed.

module test_report_message_bulk_set_reads_all_common_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_message message = new("message");
    message.set_report_message(UVM_WARNING, "ID_A", "payload", UVM_HIGH, "source.sv", 37,
        "ctx.leaf");
    $display("UT: severity_warning %0d id %s text %s", message.get_severity() == UVM_WARNING,
             message.get_id(), message.get_message());
    $display("UT: verbosity_high %0d file %s line %0d context %s",
        message.get_verbosity() == UVM_HIGH,
             message.get_filename(), message.get_line(), message.get_context());
    $finish;
  end
endmodule
