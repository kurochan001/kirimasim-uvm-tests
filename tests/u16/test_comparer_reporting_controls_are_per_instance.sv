/*
:name: test_comparer_reporting_controls_are_per_instance
:description: changing comparer report controls leaves another comparer configuration and results unchanged (IEEE 1800.2-2020 Section 16.3.5.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.5.1 16.3.5.2 16.3.5.3 16.3.3.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_reporting_controls_are_per_instance.expected
*/
// A configured policy compares a mismatching scalar while a second
// policy retains its default reporting controls and empty comparison result.

module test_comparer_reporting_controls_are_per_instance;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_comparer first = new;
    automatic uvm_comparer second = new;
    bit result;
    first.set_show_max(0);
    first.set_verbosity(UVM_HIGH);
    first.set_severity(UVM_WARNING);
    result = first.compare_field_int("value", 1, 2, 32);
    $display("UT: first max %0d high %0d warning %0d result %0d count %0d", first.get_show_max(),
             first.get_verbosity() == UVM_HIGH, first.get_severity() == UVM_WARNING,
                 result, first.get_result());
    $display("UT: second max %0d low %0d info %0d count %0d", second.get_show_max(),
             second.get_verbosity() == UVM_LOW, second.get_severity() == UVM_INFO,
                 second.get_result());
    $finish;
  end
endmodule
