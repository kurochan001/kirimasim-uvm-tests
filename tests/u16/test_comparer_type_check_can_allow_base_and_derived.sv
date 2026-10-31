/*
:name: test_comparer_type_check_can_allow_base_and_derived
:description: type checking rejects distinct registered types and can be disabled (IEEE 1800.2-2020 Section 16.3.4.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.4.2 16.3.3.4 5.3.9.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_type_check_can_allow_base_and_derived.expected
*/
// Equal base fields are insufficient when type checking is enabled.
// Disabling it permits the base and derived objects to compare by fields.

module test_comparer_type_check_can_allow_base_and_derived;
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
    second.value = 17;
    comparer.set_show_max(0);
    $display("UT: default check_type %0d", comparer.get_check_type());
    result = comparer.compare_object("value", first, second);
    $display("UT: enabled equal %0d", result);
    comparer.flush();
    comparer.set_check_type(0);
    result = comparer.compare_object("value", first, second);
    $display("UT: disabled check_type %0d equal %0d", comparer.get_check_type(), result);
    $finish;
  end
endmodule
