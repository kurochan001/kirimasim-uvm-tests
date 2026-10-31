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
