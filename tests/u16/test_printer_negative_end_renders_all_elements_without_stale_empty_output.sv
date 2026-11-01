/*
:name: test_printer_negative_end_renders_all_elements_without_stale_empty_output
:description: a negative array window bound renders all field-macro array values (IEEE 1800.2-2020 Section 16.2.6)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.6 16.2.3.5 16.2.3.7 16.2.3.9 5.3.6.2 B.2.1 B.2.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_negative_end_renders_all_elements_without_stale_empty_output.expected
*/
// The field macro supplies automatic array traversal to a built-in printer.
// Check distinct decimal values, not an implementation-specific text layout.
module test_printer_negative_end_renders_all_elements_without_stale_empty_output;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit contains_text(string text, string needle);
    if (needle.len() == 0) return 1;
    if (text.len() < needle.len()) return 0;
    for (int i = 0; i <= text.len() - needle.len(); i++)
      if (text.substr(i, i + needle.len() - 1) == needle) return 1;
    return 0;
  endfunction

  class array_record extends uvm_object;
    int values[];
    `uvm_object_utils_begin(array_record)
      `uvm_field_array_int(values, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end
    function new(string name="container"); super.new(name); endfunction
  endclass
  function automatic int present(string text, int base, int count);
    int result;
    result = 0;
    for (int i = 0; i < count; i++) result += contains_text(text, $sformatf("%0d", base + i));
    return result;
  endfunction

  initial begin
    array_record value;
    uvm_table_printer printer;
    string text;
    string updated;
    value = new();
    printer = new();
    value.values = new[6];
    foreach (value.values[i]) value.values[i] = 30101 + i;
    printer.set_begin_elements(1);
    printer.set_end_elements(-1);
    text = value.sprint(printer);
    $display("TRACE: array %s", text);
    $display("UT: all_elements %0d", present(text, 30101, 6));
    value.values = new[0];
    updated = value.sprint(printer);
    $display("UT: empty_stale %0d", present(updated, 30101, 6));
    value.values = new[3];
    foreach (value.values[i]) value.values[i] = 80101 + i;
    updated = value.sprint(printer);
    $display("UT: refilled %0d stale %0d", present(updated, 80101, 3),
             present(updated, 30101, 6));
    $finish;
  end
endmodule
