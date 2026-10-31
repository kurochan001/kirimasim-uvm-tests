/*
:name: test_comparer_real_values_compare_by_value
:description: real comparison accepts equal finite values and rejects differing finite values (IEEE 1800.2-2020 Section 16.3.3.3)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.3 16.3.3.9
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_real_values_compare_by_value.expected
*/
// Use exactly representable real values, including a negative value.
// The result count increments only for the differing comparison.

module test_comparer_real_values_compare_by_value;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_comparer comparer = new;
    bit equal_value;
    bit different_value;
    comparer.set_show_max(0);
    equal_value = comparer.compare_field_real("same", -2.25, -2.25);
    different_value = comparer.compare_field_real("different", 1.5, 1.75);
    $display("UT: equal %0d different %0d mismatches %0d", equal_value, different_value,
        comparer.get_result());
    $finish;
  end
endmodule
