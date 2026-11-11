/*
:name: test_printer_element_individual_setters_update_only_selected_fields
:description: each printer element setter replaces its selected field while preserving other fields (IEEE 1800.2-2020 Section 16.2.8.2.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.8.2.2 16.2.8.2.3 16.2.8.2.4 16.2.8.2.5 16.2.8.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_individual_setters_update_only_selected_fields.expected
*/
// What it checks:
// 1. The element name getter starts empty and returns its latest field
//    assignment.
// 2. The element type name getter starts empty and returns its latest field
//    assignment.
// 3. The element size getter starts empty and returns its latest field
//    assignment.
// 4. The element value getter starts empty and returns its latest field
//    assignment.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.8.2.3 (UVM-PRINTER-ELEMENT-NAME) gives rule 1 above.
//    Setup: Query fresh elements, update fields individually and mutate one of
//    two populated elements. Expected: Only the selected field/element changes
//    and unrelated values remain intact.
// 2. 1800.2-2020 16.2.8.2.4 (UVM-PRINTER-ELEMENT-TYPE) gives rule 2 above.
//    Setup: Query fresh elements, update fields individually and mutate one of
//    two populated elements. Expected: Only the selected field/element changes
//    and unrelated values remain intact.
// 3. 1800.2-2020 16.2.8.2.5 (UVM-PRINTER-ELEMENT-SIZE) gives rule 3 above.
//    Setup: Query fresh elements, update fields individually and mutate one of
//    two populated elements. Expected: Only the selected field/element changes
//    and unrelated values remain intact.
// 4. 1800.2-2020 16.2.8.2.6 (UVM-PRINTER-ELEMENT-VALUE) gives rule 4 above.
//    Setup: Query fresh elements, update fields individually and mutate one of
//    two populated elements. Expected: Only the selected field/element changes
//    and unrelated values remain intact.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Read all four values after each individual update to identify
// accidental writes to neighboring fields.

module test_printer_element_individual_setters_update_only_selected_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_printer_element element = new;
    element.set("a", "b", "c", "d");
    element.set_element_name("n");
    $display("UT: name_step %s %s %s %s", element.get_element_name(),
        element.get_element_type_name(),
             element.get_element_size(), element.get_element_value());
    element.set_element_type_name("t");
    $display("UT: type_step %s %s %s %s", element.get_element_name(),
        element.get_element_type_name(),
             element.get_element_size(), element.get_element_value());
    element.set_element_size("12");
    $display("UT: size_step %s %s %s %s", element.get_element_name(),
        element.get_element_type_name(),
             element.get_element_size(), element.get_element_value());
    element.set_element_value("v");
    $display("UT: value_step %s %s %s %s", element.get_element_name(),
        element.get_element_type_name(),
             element.get_element_size(), element.get_element_value());
    $finish;
  end
endmodule
