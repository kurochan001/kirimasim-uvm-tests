/*
:name: test_policy_object_stack_tracks_nested_active_policy_push_and_pop
:description: policy active-object push/pop synchronizes the receiving object's active-policy stack (IEEE 1800.2-2020 Section 16.1.3.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.3.1 16.1.3.2 16.1.3.3 5.3.14.1 5.3.14.2 5.3.14.3
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_object_stack_tracks_nested_active_policy_push_and_pop.expected
*/
// Observe both sides of the stack using the standard public APIs.
// The pinned library lacks get_active_policy; retain the normative calls
// and expected handles rather than substituting policy-side depth checks.
module test_policy_object_stack_tracks_nested_active_policy_push_and_pop;
  import uvm_pkg::*;
  class item extends uvm_object;
    function new(); super.new("item"); endfunction
  endclass
  initial begin
    automatic item value = new();
    automatic uvm_copier first = new();
    automatic uvm_copier second = new();
    uvm_object popped;
    $display("UT: initial object_empty %0d", value.get_active_policy() == null);
    first.push_active_object(value);
    $display("UT: first object_policy %0d policy_object %0d",
             value.get_active_policy() == first, first.get_active_object() == value);
    second.push_active_object(value);
    $display("UT: second object_policy %0d first_top %0d second_top %0d",
             value.get_active_policy() == second, first.get_active_object() == value,
             second.get_active_object() == value);
    popped = second.pop_active_object();
    $display("UT: popped_second object_policy %0d popped_same %0d second_empty %0d",
             value.get_active_policy() == first, popped == value,
             second.get_active_object() == null);
    popped = first.pop_active_object();
    $display("UT: popped_first object_empty %0d popped_same %0d first_empty %0d",
             value.get_active_policy() == null, popped == value,
             first.get_active_object() == null);
    $finish;
  end
endmodule
