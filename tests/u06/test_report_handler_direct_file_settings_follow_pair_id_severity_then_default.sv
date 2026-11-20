/*
:name: test_report_handler_direct_file_settings_follow_pair_id_severity_then_default
:description: a report handler returns the file of a severity-id pair, then of an id, then of a severity, then the default file, when configured directly (IEEE 1800.2-2020 Section 6.4.5.2)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.4.5.2 6.4.5.1 6.3.8.1 F.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_handler_direct_file_settings_follow_pair_id_severity_then_default.expected
*/
// What it checks:
// A file descriptor set for a severity-id pair is returned before one set for
// the id alone, one set for an id before one set for the severity, and one set
// for a severity before the default descriptor.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.4.5.2 (UVM-HANDLER-DIRECT-FILE-PRECEDENCE) gives the rule
// above, and 6.4.5.1 returns the stored descriptor. Setup: take the handler of
// a report object with get_report_handler (6.3.8.1) and set four different
// descriptor values: the default, severity UVM_ERROR, id ID_A, and the pair
// UVM_ERROR and ID_A. Expected: UVM_INFO with ID_Z gives the default, UVM_ERROR
// with ID_Z the severity's, UVM_INFO with ID_A the id's, and UVM_ERROR with
// ID_A the pair's.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The descriptors are only stored and returned: no report is issued, so
// nothing is written to them, and the test opens no file.
module test_report_handler_direct_file_settings_follow_pair_id_severity_then_default;
  import uvm_pkg::*;

  initial begin
    automatic uvm_report_object subject = new("subject");
    automatic uvm_report_handler handler = subject.get_report_handler();
    automatic UVM_FILE default_file = 32'h0000_0010;
    automatic UVM_FILE severity_file = 32'h0000_0020;
    automatic UVM_FILE id_file = 32'h0000_0040;
    automatic UVM_FILE pair_file = 32'h0000_0080;
    handler.set_default_file(default_file);
    handler.set_severity_file(UVM_ERROR, severity_file);
    handler.set_id_file("ID_A", id_file);
    handler.set_severity_id_file(UVM_ERROR, "ID_A", pair_file);
    $display("UT: default %0d severity %0d id %0d pair %0d",
             handler.get_file_handle(UVM_INFO, "ID_Z") == default_file,
             handler.get_file_handle(UVM_ERROR, "ID_Z") == severity_file,
             handler.get_file_handle(UVM_INFO, "ID_A") == id_file,
             handler.get_file_handle(UVM_ERROR, "ID_A") == pair_file);
    $finish;
  end
endmodule
