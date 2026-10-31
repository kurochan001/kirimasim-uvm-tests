/*
:name: test_printer_controls_are_per_instance_and_survive_flush
:description: printer controls belong to their instance and survive clearing print data (IEEE 1800.2-2020 Section 16.2.5.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.1 16.2.5.2 16.2.5.3 16.2.5.4 16.2.5.5 16.2.5.10 16.2.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_controls_are_per_instance_and_survive_flush.expected
*/
// Flush clears accumulated print data. Name, type, size, ID, radix and
// maximum-depth controls retain their settings and leave another printer alone.

module test_printer_controls_are_per_instance_and_survive_flush;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_table_printer first = new;
    automatic uvm_table_printer second = new;
    first.set_name_enabled(0);
    first.set_type_name_enabled(0);
    first.set_size_enabled(0);
    first.set_id_enabled(0);
    first.set_radix_enabled(0);
    first.set_max_depth(0);
    first.flush();
    $display("UT: retained %0d %0d %0d %0d %0d depth %0d", first.get_name_enabled(),
             first.get_type_name_enabled(), first.get_size_enabled(), first.get_id_enabled(),
             first.get_radix_enabled(), first.get_max_depth());
    $display("UT: independent %0d %0d %0d %0d %0d depth %0d", second.get_name_enabled(),
             second.get_type_name_enabled(), second.get_size_enabled(), second.get_id_enabled(),
             second.get_radix_enabled(), second.get_max_depth());
    $finish;
  end
endmodule
