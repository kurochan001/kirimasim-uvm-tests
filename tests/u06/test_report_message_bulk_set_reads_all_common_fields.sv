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
