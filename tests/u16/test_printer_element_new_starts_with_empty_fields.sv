/*
:name: test_printer_element_new_starts_with_empty_fields
:description: a new printer element has empty name type size and value fields (IEEE 1800.2-2020 Section 16.2.8.2.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.8.2.1 16.2.8.2.3 16.2.8.2.4 16.2.8.2.5 16.2.8.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_new_starts_with_empty_fields.expected
*/
// Observe the specified empty element fields before any setter call.
// These fields are independent of built-in printer output formatting.

module test_printer_element_new_starts_with_empty_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_printer_element element = new;
    $display("UT: empty name %0d type %0d size %0d value %0d", element.get_element_name() == "",
             element.get_element_type_name() == "", element.get_element_size() == "",
                 element.get_element_value() == "");
    $finish;
  end
endmodule
