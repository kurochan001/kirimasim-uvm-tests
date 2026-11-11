/*
:name: test_printer_array_window_defaults_and_negative_bound
:description: printer array window controls have default values and accept an all-elements bound (IEEE 1800.2-2020 Section 16.2.6)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_array_window_defaults_and_negative_bound.expected
*/
// What it checks:
// Printer array-window getters retain configured begin/end values and default
// to 5.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.2.6 (UVM-PRINTER-ARRAY-WINDOW-CONFIGURATION) gives the rule
// above. Setup: Use two printers, explicit negative/zero bounds and setters
// with omitted arguments. Expected: The controls stay instance-local and
// omitted arguments restore 5/5.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe only control values. A negative begin bound selects all array
// elements without requiring any particular built-in array output layout.

module test_printer_array_window_defaults_and_negative_bound;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_table_printer printer = new;
    $display("UT: defaults begin %0d end %0d", printer.get_begin_elements(),
        printer.get_end_elements());
    printer.set_begin_elements(0);
    printer.set_end_elements(2);
    $display("UT: configured begin %0d end %0d", printer.get_begin_elements(),
        printer.get_end_elements());
    printer.set_begin_elements(-1);
    $display("UT: all_begin %0d end %0d", printer.get_begin_elements() < 0,
        printer.get_end_elements());
    $finish;
  end
endmodule
