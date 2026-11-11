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
// What it checks:
// 1. Pushing an active object also pushes that policy onto the object
//    active-policy stack.
// 2. Popping an active object also pops the policy from that object
//    active-policy stack.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.1.3.1 (UVM-POLICY-ACTIVE-POLICY-SYNC) gives rule 1 above.
//    Setup: Observe both the policy-side object stack and the object-side
//    policy stack. Expected: Both sides identify the same newly active
//    object/policy relationship.
// 2. 1800.2-2020 16.1.3.2 (UVM-POLICY-POP-ACTIVE-POLICY-SYNC) gives rule 2
//    above. Setup: Push one object through two distinct policies, then pop the
//    second and first in order. Expected: Object active policy restores the
//    first then null; popped objects are exact and each emptied policy reports
//    null.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
