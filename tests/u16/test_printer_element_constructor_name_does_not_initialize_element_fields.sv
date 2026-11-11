/*
:name: test_printer_element_constructor_name_does_not_initialize_element_fields
:description: named printer elements retain empty element fields until explicitly set (IEEE 1800.2-2020 Section 16.2.8.2.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.8.2.1 16.2.8.2.2 16.2.8.2.3 16.2.8.2.4 16.2.8.2.5 16.2.8.2.6 5.3.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_constructor_name_does_not_initialize_element_fields.expected
*/
// What it checks:
// Constructing a printer element gives its object the supplied name.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.2.8.2.1 (UVM-PRINTER-ELEMENT-CONSTRUCTOR-NAME) gives the rule
// above. Setup: Construct two named elements before assigning any element
// fields. Expected: Object names reflect constructor arguments without
// substituting them for element-field values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The constructor names the object. Its element fields still have
// their documented empty values until set or individual setters are called.

module test_printer_element_constructor_name_does_not_initialize_element_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_printer_element first = new("first_object");
    automatic uvm_printer_element second = new("second_object");
    first.set("field", "int", "8", "7");
    $display("UT: object_names %s %s", first.get_name(), second.get_name());
    $display("UT: second_empty %0d %0d %0d %0d", second.get_element_name() == "",
             second.get_element_type_name() == "", second.get_element_size() == "",
                 second.get_element_value() == "");
    $finish;
  end
endmodule
