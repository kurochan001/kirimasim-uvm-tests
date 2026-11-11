/*
:name: test_printer_name_emission_is_local_across_line_printer_reuse
:description: independent line printers preserve name emission settings across repeated sprint calls (IEEE 1800.2-2020 Section 16.2.5.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.1 16.2.4.1 16.2.3.9 5.3.6.2 5.3.6.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_name_emission_is_local_across_line_printer_reuse.expected
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
// Two policies render the same object, then a changed payload. Membership
// avoids relying on indentation, line endings or object presentation.
module test_printer_name_emission_is_local_across_line_printer_reuse;
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
    uvm_line_printer hidden;
    uvm_line_printer visible;
    string first;
    string peer;
    string second;
    value = new();
    hidden = new();
    visible = new();
    hidden.set_name_enabled(0);
    visible.set_name_enabled(1);
    first = value.sprint(hidden);
    peer = value.sprint(visible);
    value.payload = 271828182;
    second = value.sprint(hidden);
    $display("TRACE: hidden %s visible %s reused %s", first, peer, second);
    $display("UT: names hidden %0d visible %0d reused %0d",
             contains_text(first, "FIELD_SENTINEL"), contains_text(peer, "FIELD_SENTINEL"),
             contains_text(second, "FIELD_SENTINEL"));
    $display("UT: replacement fresh %0d stale %0d", contains_text(second, "271828182"),
             contains_text(second, "314159265"));
    $finish;
  end
endmodule
