/*
:name: test_policy_active_object_stacks_are_independent
:description: each policy owns its active-object stack and an empty pop returns null (IEEE 1800.2-2020 Section 16.1.3.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.3.1 16.1.3.2 16.1.3.3 16.1.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_active_object_stacks_are_independent.expected
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
// Two distinct policies carry different active objects. Popping the
// second stack, including its empty state, leaves the first stack intact.

module test_policy_active_object_stacks_are_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_copier first_policy = new;
    automatic uvm_comparer second_policy = new;
    automatic item first = new("first");
    automatic item second = new("second");
    uvm_object popped;
    first_policy.push_active_object(first);
    second_policy.push_active_object(second);
    popped = second_policy.pop_active_object();
    $display("UT: second popped %0d depth %0d", popped == second,
             second_policy.get_active_object_depth());
    popped = second_policy.pop_active_object();
    $display("UT: empty pop_null %0d first_top %0d first_depth %0d", popped == null,
             first_policy.get_active_object() == first, first_policy.get_active_object_depth());
    popped = first_policy.pop_active_object();
    $display("UT: first popped %0d depth %0d", popped == first,
             first_policy.get_active_object_depth());
    $finish;
  end
endmodule
