/*
:name: test_comparer_deep_and_reference_policies_differ
:description: deep comparison accepts equal fields of distinct objects (IEEE 1800.2-2020 Section 16.3.4.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.4.1 16.3.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_deep_and_reference_policies_differ.expected
*/
// What it checks:
// Reference comparison uses handle identity while deep comparison inspects
// object fields.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.3.4.1 (UVM-COMPARER-RECURSION-MODE) gives the rule above.
// Setup: Compare an alias and a distinct equal-valued object with independent
// comparers. Expected: Only the alias passes reference comparison; equal
// fields can pass deep comparison.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independent comparers inspect the same distinct pair under reference
// and deep policies. Neither policy inherits the other comparison cache.

module test_comparer_deep_and_reference_policies_differ;
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
    automatic base_value second = new;
    automatic uvm_comparer reference_policy = new;
    automatic uvm_comparer deep_policy = new;
    bit reference_result;
    bit deep_result;
    first.value = 21;
    second.value = 21;
    reference_policy.set_show_max(0);
    deep_policy.set_show_max(0);
    reference_policy.set_recursion_policy(UVM_REFERENCE);
    deep_policy.set_recursion_policy(UVM_DEEP);
    reference_result = reference_policy.compare_object("value", first, second);
    deep_result = deep_policy.compare_object("value", first, second);
    $display("UT: reference %0d deep %0d", reference_result, deep_result);
    $finish;
  end
endmodule
