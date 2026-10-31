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
