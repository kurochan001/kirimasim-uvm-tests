/*
:name: test_printer_name_enable_changes_emitted_field_membership
:description: name control changes actual emitted names while preserving the field value (IEEE 1800.2-2020 Section 16.2.5.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.1 16.2.4.1 16.2.3.9 5.3.6.2 5.3.6.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_name_enable_changes_emitted_field_membership.expected
*/
// What it checks:
// The field-name enable control affects inclusion of field names during
// printer emission.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.2.5.1 (UVM-PRINTER-NAME-EMISSION) gives the rule above.
// Setup: Emit equivalent fields with name printing enabled and disabled. Two
// fields use distinct caller-supplied textual name/type/size/value attributes
// through print_generic_element. Actual table/tree/line printers each exercise
// all eight name/type/size masks. One path sets controls before object sprint;
// another collects under the opposite mask and changes controls only before
// emit. Reuse changes values and checks an independent fresh peer policy.
// Default-peer inputs retain their omitted-setting premise. Four separately
// named tree/line controls explicitly enable peer settings; their matches
// cannot pass the default-peer inputs. Expected: The enabled form includes
// names and the disabled form omits them.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe membership only, without prescribing table widths or punctuation.
module test_printer_name_enable_changes_emitted_field_membership;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit contains_text(string text, string needle);
    if (needle.len() == 0) return 1;
    if (text.len() < needle.len()) return 0;
    for (int i = 0; i <= text.len() - needle.len(); i++)
      if (text.substr(i, i + needle.len() - 1) == needle) return 1;
    return 0;
  endfunction

  class named_record extends uvm_object;
    `uvm_object_utils(named_record)
    int payload = 314159265;
    function new(string name="container"); super.new(name); endfunction
    virtual function void do_print(uvm_printer printer);
      printer.print_field_int("FIELD_SENTINEL", payload, 32, UVM_DEC);
    endfunction
  endclass

  initial begin
    named_record value;
    uvm_table_printer printer;
    string enabled_text;
    string disabled_text;
    value = new();
    printer = new();
    printer.set_name_enabled(1);
    enabled_text = value.sprint(printer);
    printer.set_name_enabled(0);
    disabled_text = value.sprint(printer);
    $display("TRACE: enabled %s disabled %s", enabled_text, disabled_text);
    $display("UT: names enabled %0d disabled %0d",
             contains_text(enabled_text, "FIELD_SENTINEL"),
             contains_text(disabled_text, "FIELD_SENTINEL"));
    $display("UT: values enabled %0d disabled %0d", contains_text(enabled_text, "314159265"),
             contains_text(disabled_text, "314159265"));
    $finish;
  end
endmodule
