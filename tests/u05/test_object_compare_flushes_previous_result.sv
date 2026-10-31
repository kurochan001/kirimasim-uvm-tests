/*
:name: test_object_compare_flushes_previous_result
:description: a new top-level comparison clears previous miscompares (IEEE 1800.2-2020 Section 5.3.9.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.9.1 5.3.9.2 16.3.2.2 16.3.3.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_compare_flushes_previous_result.expected
*/
// The object comparison entry point flushes the comparer before a new
// operation. Compare both fields even when the first one differs.

module test_object_compare_flushes_previous_result;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class datum extends uvm_object;
    `uvm_object_utils(datum)
    int value = 0;
    string label = "";
    function new(string name="datum"); super.new(name); endfunction
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      datum other;
      bit same_value;
      bit same_label;
      if (!$cast(other, rhs)) return 0;
      same_value = comparer.compare_field_int("value", value, other.value, 32);
      same_label = comparer.compare_string("label", label, other.label);
      return same_value && same_label;
    endfunction
  endclass
  initial begin
    automatic datum lhs = new;
    automatic datum rhs = new;
    automatic uvm_comparer comparer = new;
    bit same;
    lhs.value = 8;
    lhs.label = "left";
    rhs.value = 9;
    rhs.label = "right";
    same = lhs.compare(rhs, comparer);
    $display("UT: different %0d count %0d", same, comparer.get_result());
    rhs.value = 8;
    rhs.label = "left";
    same = lhs.compare(rhs, comparer);
    $display("UT: equal %0d count %0d empty %0d", same, comparer.get_result(),
             comparer.get_miscompares() == "");
    $finish;
  end
endmodule
