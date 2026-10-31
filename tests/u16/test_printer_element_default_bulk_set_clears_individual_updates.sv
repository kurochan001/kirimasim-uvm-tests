/*
:name: test_printer_element_default_bulk_set_clears_individual_updates
:description: default printer element bulk set clears values assigned through individual setters (IEEE 1800.2-2020 Section 16.2.8.2.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.8.2.2 16.2.8.2.3 16.2.8.2.4 16.2.8.2.5 16.2.8.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_default_bulk_set_clears_individual_updates.expected
*/
// Assign all fields individually, then call set with no arguments.
// Every argument defaults to the empty string.

module test_printer_element_default_bulk_set_clears_individual_updates;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_printer_element element = new;
    element.set_element_name("field");
    element.set_element_type_name("packet");
    element.set_element_size("16");
    element.set_element_value("19");
    element.set();
    $display("UT: cleared %0d %0d %0d %0d", element.get_element_name() == "",
             element.get_element_type_name() == "", element.get_element_size() == "",
                 element.get_element_value() == "");
    $finish;
  end
endmodule
