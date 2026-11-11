/*
:name: test_printer_element_bulk_set_replaces_all_fields
:description: printer element bulk set replaces fields and defaults omitted arguments to empty strings (IEEE 1800.2-2020 Section 16.2.8.2.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.8.2.2 16.2.8.2.3 16.2.8.2.4 16.2.8.2.5 16.2.8.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_bulk_set_replaces_all_fields.expected
*/
// What it checks:
// Printer-element set assigns all four fields and uses empty defaults for
// omitted arguments.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.2.8.2.2 (UVM-PRINTER-ELEMENT-BULK-SET) gives the rule above.
// Setup: Populate all fields, then call with one named argument or no
// arguments. Expected: Previously assigned omitted fields clear rather than
// retaining old values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Set all four explicit values, then use one named argument. Omitted
// arguments have empty-string defaults and replace their previous values.

module test_printer_element_bulk_set_replaces_all_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_printer_element element = new;
    element.set("field", "packet", "8", "7");
    $display("UT: fields %s %s %s %s", element.get_element_name(), element.get_element_type_name(),
             element.get_element_size(), element.get_element_value());
    element.set(.element_value("tail"));
    $display("UT: omitted_empty %0d %0d %0d value %s", element.get_element_name() == "",
             element.get_element_type_name() == "", element.get_element_size() == "",
                 element.get_element_value());
    $finish;
  end
endmodule
