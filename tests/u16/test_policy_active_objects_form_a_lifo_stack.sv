/*
:name: test_policy_active_objects_form_a_lifo_stack
:description: policy active objects are pushed and popped in last-in first-out order (IEEE 1800.2-2020 Section 16.1.3.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.3.1 16.1.3.2 16.1.3.3 16.1.3.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_active_objects_form_a_lifo_stack.expected
*/
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
    uvm_copier policy = new;
    item first = new("first");
    item second = new("second");
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
