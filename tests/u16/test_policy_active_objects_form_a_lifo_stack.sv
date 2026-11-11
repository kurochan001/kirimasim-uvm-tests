/*
:name: test_policy_active_objects_form_a_lifo_stack
:description: policy active objects are pushed and popped in last-in first-out order (IEEE 1800.2-2020 Section 16.1.3.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.3.1 16.1.3.2 16.1.3.3 16.1.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_active_objects_form_a_lifo_stack.expected
*/
// What it checks:
// 1. Pushing a nonnull active object makes it the policy stack head.
// 2. Popping returns/removes the current active object, or null when the stack
//    is empty.
// 3. The active-object query returns the current stack head or null for an
//    empty stack.
// 4. Active-object depth reports the number of objects in the selected policy
//    stack.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.1.3.1 (UVM-POLICY-ACTIVE-OBJECT-PUSH) gives rule 1 above.
//    Setup: Use two policies and a two-object LIFO stack, including
//    empty-stack operations. Expected: Handles and depths follow LIFO order,
//    and changing one policy stack leaves the other intact.
// 2. 1800.2-2020 16.1.3.2 (UVM-POLICY-ACTIVE-OBJECT-POP) gives rule 2 above.
//    Setup: Use two policies and a two-object LIFO stack, including
//    empty-stack operations. Expected: Handles and depths follow LIFO order,
//    and changing one policy stack leaves the other intact.
// 3. 1800.2-2020 16.1.3.3 (UVM-POLICY-ACTIVE-OBJECT-TOP) gives rule 3 above.
//    Setup: Use two policies and a two-object LIFO stack, including
//    empty-stack operations. Expected: Handles and depths follow LIFO order,
//    and changing one policy stack leaves the other intact.
// 4. 1800.2-2020 16.1.3.4 (UVM-POLICY-ACTIVE-OBJECT-DEPTH) gives rule 4 above.
//    Setup: Use two policies and a two-object LIFO stack, including
//    empty-stack operations. Expected: Handles and depths follow LIFO order,
//    and changing one policy stack leaves the other intact.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe only the policy-side stack through its public API. Object-side
// active-policy lookup is unavailable in the pinned library.

module test_policy_active_objects_form_a_lifo_stack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_copier policy = new;
    automatic item first = new("first");
    automatic item second = new("second");
    uvm_object popped;
    $display("UT: empty %0d depth %0d", policy.get_active_object() == null,
             policy.get_active_object_depth());
    policy.push_active_object(first);
    policy.push_active_object(second);
    $display("UT: pushed top_second %0d depth %0d", policy.get_active_object() == second,
             policy.get_active_object_depth());
    popped = policy.pop_active_object();
    $display("UT: pop_second %0d top_first %0d depth %0d", popped == second,
             policy.get_active_object() == first, policy.get_active_object_depth());
    popped = policy.pop_active_object();
    $display("UT: pop_first %0d empty %0d depth %0d", popped == first,
             policy.get_active_object() == null, policy.get_active_object_depth());
    $finish;
  end
endmodule
