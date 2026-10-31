/*
:name: test_comparer_reference_policy_checks_handle_identity
:description: reference comparison distinguishes object identity from equal field values (IEEE 1800.2-2020 Section 16.3.4.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.4.1 16.3.3.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_reference_policy_checks_handle_identity.expected
*/
// One alias refers to the original object while another object has the
// same fields. A reference policy accepts only the alias.

module test_comparer_reference_policy_checks_handle_identity;
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
    base_value first = new;
    base_value second = new;
    base_value alias_value = first;
    uvm_comparer comparer = new;
    bit result;
    first.value = 21;
    second.value = 21;
    comparer.set_show_max(0);
    comparer.set_recursion_policy(UVM_REFERENCE);
    result = comparer.compare_object("alias", first, alias_value);
    $display("UT: same handle %0d", result);
    comparer.flush();
    comparer.set_recursion_policy(UVM_REFERENCE);
    result = comparer.compare_object("distinct", first, second);
    $display("UT: distinct equal fields %0d", result);
    $finish;
  end
endmodule
