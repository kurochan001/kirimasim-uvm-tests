/*
:name: test_function_phase_count_query_reports_error
:description: an objection count query on a function phase reports an error (IEEE 1800.2-2020 Section 9.3.1.7)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.7 9.3.1.7.1 9.3.1.7.4 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_function_phase_count_query_reports_error.expected
*/
// What it checks:
// Using the count objection operation on a non-task phase reports an error.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.3.1.7 (UVM-FUNCTION-PHASE-COUNT-ERROR) gives the rule above.
// Setup: Use a function phase with no associated objection and discard invalid
// returned values. Expected: The operation increases error counts without
// requiring particular diagnostic text.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Discard the count returned by an invalid query. Only the required
// error is observed; no value after the error is prescribed.

module test_function_phase_count_query_reports_error;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_phase schedule = new("local", UVM_PHASE_SCHEDULE);
    automatic item actor = new("actor");
    automatic uvm_root root = uvm_root::get();
    automatic uvm_report_server server = uvm_report_server::get_server();
    uvm_phase node;
    int errors;
    schedule.add(uvm_connect_phase::get());
    node = schedule.find(uvm_connect_phase::get());
    if (node == null) $fatal(1, "function phase node not found");
    root.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    $display("UT: no_objection %0d", node.get_objection() == null);
    errors = server.get_severity_count(UVM_ERROR);
    void'(node.get_objection_count(actor));
    $display("UT: count_reports_error %0d", server.get_severity_count(UVM_ERROR) > errors);
    $finish;
  end
endmodule
