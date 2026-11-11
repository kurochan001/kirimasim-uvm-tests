/*
:name: test_sequence_finish_item_null_input_reports_error_before_mid_do
:description: finish_item rejects invalid input with ERROR and returns before invoking mid_do (IEEE 1800.2-2020 Section 14.2.6.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.6.3 6.6.3.2 6.6.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_finish_item_null_input_reports_error_before_mid_do.expected
*/
// What it checks:
// finish_item rejects null with ERROR and returns before mid_do.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.2.6.3 (UVM-SEQUENCE-FINISH-NULL-ERROR-RETURN) gives the rule
// above. Setup: Pass null to an unbound sequence finish call. Expected: The
// call returns with one ERROR, no FATAL and no mid_do call.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Exercise the required argument/context guard before any submission.
// Count original report severity and require an immediate return. The
// pinned library lacks these guards; retain the normative ERROR and return
// as spec-only even when the faulty path terminates during dereference.

module test_sequence_finish_item_null_input_reports_error_before_mid_do;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class child_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(child_sequence)
    function new(string name="child_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass
  class severity_probe extends uvm_report_catcher;
    int errors = 0;
    int fatals = 0;
    function new(string name="severity_probe"); super.new(name); endfunction
    function action_e catch();
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      if (get_severity() == UVM_FATAL) begin fatals++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  class producer extends uvm_sequence#(packet);
    `uvm_object_utils(producer)
    int mid_calls = 0;
    bit returned = 0;
    function new(string name="producer"); super.new(name); endfunction
    function void mid_do(uvm_sequence_item this_item); mid_calls++; endfunction
    task body();
      packet item = new("item");
      child_sequence child = new("child");
      finish_item(null);
      returned = 1;
    endtask
  endclass
  initial begin
    automatic producer value = new("value");
    automatic severity_probe probe = new;
    uvm_report_cb::add(null, probe);
    value.start(null);
    $display("UT: returned %0d mid_calls %0d errors %0d fatals %0d", value.returned,
             value.mid_calls, probe.errors, probe.fatals);
    $finish;
  end
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
