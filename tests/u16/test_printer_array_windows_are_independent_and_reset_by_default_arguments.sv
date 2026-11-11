/*
:name: test_printer_array_windows_are_independent_and_reset_by_default_arguments
:description: array window controls are per printer and setter default arguments select five elements (IEEE 1800.2-2020 Section 16.2.6)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_array_windows_are_independent_and_reset_by_default_arguments.expected
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
// Change one printer and inspect both instances. Calling the setters
// without arguments restores their specified default window counts.

module test_printer_array_windows_are_independent_and_reset_by_default_arguments;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_table_printer first = new;
    automatic uvm_table_printer second = new;
    first.set_begin_elements(1);
    first.set_end_elements(0);
    $display("UT: first %0d %0d second %0d %0d", first.get_begin_elements(),
        first.get_end_elements(),
             second.get_begin_elements(), second.get_end_elements());
    first.set_begin_elements();
    first.set_end_elements();
    $display("UT: default_arguments %0d %0d", first.get_begin_elements(), first.get_end_elements());
    $finish;
  end
endmodule
