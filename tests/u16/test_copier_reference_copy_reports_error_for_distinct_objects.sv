/*
:name: test_copier_reference_copy_reports_error_for_distinct_objects
:description: copy_object under reference recursion emits ERROR without constraining the result (IEEE 1800.2-2020 Section 16.6.4.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.4.1 16.6.3 5.3.8.2 6.6.3.2 6.6.5 D.4.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_reference_copy_reports_error_for_distinct_objects.expected
*/
// What it checks:
// Calling copy_object under UVM_REFERENCE recursion reports an error.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.6.4.1 (UVM-COPIER-REFERENCE-MODE-ERROR) gives the rule above.
// Setup: Set reference mode and call the object-copy entry point rather than
// assigning a handle. Expected: The call reports an error; its undefined copy
// result is not inspected.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The invalid copy result and both invalid operands are left uninspected.
// A different copier and fresh operands provide an independent deep control.
module test_copier_reference_copy_reports_error_for_distinct_objects;
  import uvm_pkg::*;

  class item extends uvm_object;
    int payload = 0;
    function new(string name="item"); super.new(name); endfunction
    virtual function void do_copy(uvm_object rhs);
      item source;
      if (!$cast(source, rhs)) $fatal(1, "unexpected copy fixture type");
      payload = source.payload;
    endfunction
  endclass
  class error_probe extends uvm_report_catcher;
    int errors = 0;
    function new(string name="error_probe"); super.new(name); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_ERROR) begin
        errors++;
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass

  initial begin
    uvm_copier invalid;
    uvm_copier control;
    error_probe probe;
    item source;
    item target;
    item good_source;
    item good_target;
    invalid = new();
    control = new();
    probe = new();
    source = new("source");
    target = new("target");
    good_source = new("good_source");
    good_target = new("good_target");
    source.payload = 17;
    target.payload = 29;
    good_source.payload = 61;
    uvm_report_cb::add(null, probe);
    invalid.set_recursion_policy(UVM_REFERENCE);
    invalid.copy_object(target, source);
    $display("UT: reference_error %0d", probe.errors > 0);
    uvm_report_cb::delete(null, probe);
    control.set_recursion_policy(UVM_DEEP);
    control.copy_object(good_target, good_source);
    $display("UT: deep_control %0d distinct %0d", good_target.payload == 61,
             good_target != good_source);
    $finish;
  end
endmodule
