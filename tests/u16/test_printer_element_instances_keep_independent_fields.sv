/*
:name: test_printer_element_instances_keep_independent_fields
:description: printer element instances retain independent name type size and value fields (IEEE 1800.2-2020 Section 16.2.8.2.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.8.2.2 16.2.8.2.3 16.2.8.2.4 16.2.8.2.5 16.2.8.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_instances_keep_independent_fields.expected
*/
// Populate both instances explicitly, replace one, and observe the
// other through its retained handle.

module test_printer_element_instances_keep_independent_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_printer_element first = new;
    automatic uvm_printer_element second = new;
    first.set("first", "packet", "8", "1");
    second.set("second", "frame", "9", "2");
    first.set("changed", "new", "16", "3");
    $display("UT: distinct %0d", first != second);
    $display("UT: first %s %s %s %s", first.get_element_name(),
        first.get_element_type_name(), first.get_element_size(), first.get_element_value());
    $display("UT: second %s %s %s %s", second.get_element_name(),
        second.get_element_type_name(), second.get_element_size(), second.get_element_value());
    $finish;
  end
endmodule
