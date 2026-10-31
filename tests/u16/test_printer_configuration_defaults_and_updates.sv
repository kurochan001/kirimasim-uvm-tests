/*
:name: test_printer_configuration_defaults_and_updates
:description: printer controls start at their specified defaults and accept updates (IEEE 1800.2-2020 Section 16.2.5.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.1 16.2.5.2 16.2.5.3 16.2.5.4 16.2.5.5 16.2.5.10
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_configuration_defaults_and_updates.expected
*/
// Check the specified control values using getters. No built-in output
// layout, indentation, object ID text or radix prefix is compared.

module test_printer_configuration_defaults_and_updates;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    uvm_table_printer printer = new;
    $display("UT: defaults %0d %0d %0d %0d %0d depth %0d", printer.get_name_enabled(),
             printer.get_type_name_enabled(), printer.get_size_enabled(), printer.get_id_enabled(),
             printer.get_radix_enabled(), printer.get_max_depth());
    printer.set_name_enabled(0);
    printer.set_type_name_enabled(0);
    printer.set_size_enabled(0);
    printer.set_id_enabled(0);
    printer.set_radix_enabled(0);
    printer.set_max_depth(2);
    $display("UT: updated %0d %0d %0d %0d %0d depth %0d", printer.get_name_enabled(),
             printer.get_type_name_enabled(), printer.get_size_enabled(), printer.get_id_enabled(),
             printer.get_radix_enabled(), printer.get_max_depth());
    $finish;
  end
endmodule
