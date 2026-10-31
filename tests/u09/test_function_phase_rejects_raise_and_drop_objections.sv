/*
:name: test_function_phase_rejects_raise_and_drop_objections
:description: raising and dropping an objection on a function phase report errors (IEEE 1800.2-2020 Section 9.3.1.7)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.7 9.3.1.7.1 9.3.1.7.2 9.3.1.7.3 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_function_phase_rejects_raise_and_drop_objections.expected
*/
// Function phases have no objection. Observe error-count increases,
// without depending on report identifiers, wording or the number of reports.

module test_function_phase_rejects_raise_and_drop_objections;
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
    schedule.add(uvm_build_phase::get());
    node = schedule.find(uvm_build_phase::get());
    if (node == null) $fatal(1, "function phase node not found");
    root.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    $display("UT: no_objection %0d", node.get_objection() == null);
    errors = server.get_severity_count(UVM_ERROR);
    node.raise_objection(actor);
    $display("UT: raise_reports_error %0d", server.get_severity_count(UVM_ERROR) > errors);
    errors = server.get_severity_count(UVM_ERROR);
    node.drop_objection(actor);
    $display("UT: drop_reports_error %0d", server.get_severity_count(UVM_ERROR) > errors);
    $finish;
  end
endmodule
