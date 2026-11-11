/*
:name: test_comparer_disabled_type_check_still_compares_fields
:description: disabling type checking retains comparisons of the object fields (IEEE 1800.2-2020 Section 16.3.4.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.4.2 16.3.3.4 16.3.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_disabled_type_check_still_compares_fields.expected
*/
// What it checks:
// Type checking defaults enabled and can be disabled without disabling field
// comparison.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.3.4.2 (UVM-COMPARER-TYPE-CHECK) gives the rule above. Setup:
// Compare base/derived objects with equal and differing base fields. Expected:
// Enabled checks reject differing types; disabled checks compare the field
// values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The same base and derived pair first differs by a field, then agrees.
// Flush the comparison state before comparing the changed field again.

module test_comparer_disabled_type_check_still_compares_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class base_value extends uvm_object;
    `uvm_object_utils(base_value)
    int value = 0;
    function new(string name="base_value"); super.new(name); endfunction
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      base_value other;
      if (!$cast(other, rhs)) return 0;
      return super.do_compare(rhs, comparer) &&
             comparer.compare_field_int("value", value, other.value, 32);
    endfunction
  endclass
  class derived_value extends base_value;
    `uvm_object_utils(derived_value)
    function new(string name="derived_value"); super.new(name); endfunction
  endclass

  initial begin
    automatic base_value first = new;
    automatic derived_value second = new;
    automatic uvm_comparer comparer = new;
    bit result;
    first.value = 17;
    second.value = 18;
    comparer.set_show_max(0);
    comparer.set_check_type(0);
    result = comparer.compare_object("value", first, second);
    $display("UT: different fields %0d", result);
    comparer.flush();
    comparer.set_check_type(0);
    second.value = 17;
    result = comparer.compare_object("value", first, second);
    $display("UT: equal fields %0d", result);
    $finish;
  end
endmodule
