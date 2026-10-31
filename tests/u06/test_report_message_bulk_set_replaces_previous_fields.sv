/*
:name: test_report_message_bulk_set_replaces_previous_fields
:description: bulk message initialization replaces prior field values including empty strings (IEEE 1800.2-2020 Section 6.2.4.10)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.2.4.10 6.2.4.1 6.2.4.2 6.2.4.3 6.2.4.4 6.2.4.5 6.2.4.6 6.2.4.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_message_bulk_set_replaces_previous_fields.expected
*/
// Set nonempty values first, then replace every common field. Inspect
// empty strings by equality rather than by report formatting.

module test_report_message_bulk_set_replaces_previous_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_message message = new;
    message.set_report_message(UVM_ERROR, "OLD", "old payload", UVM_HIGH, "old.sv", 88, "old.ctx");
    message.set_report_message(UVM_INFO, "", "", UVM_NONE, "", 0, "");
    $display("UT: info %0d none %0d line %0d", message.get_severity() == UVM_INFO,
             message.get_verbosity() == UVM_NONE, message.get_line());
    $display("UT: empty id %0d text %0d filename %0d context %0d", message.get_id() == "",
             message.get_message() == "", message.get_filename() == "",
                 message.get_context() == "");
    $finish;
  end
endmodule
