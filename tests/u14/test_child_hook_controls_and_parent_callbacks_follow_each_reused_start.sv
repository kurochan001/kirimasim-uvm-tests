/*
:name: test_child_hook_controls_and_parent_callbacks_follow_each_reused_start
:description: reusing a child sequence applies each call_pre_post choice and current parent hooks (14.2.3.8)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.3.8 14.2.3.3 14.2.3.1 14.2.3.4 14.2.3.5 14.2.3.7 14.2.3.2 14.2.3.6 14.2.3.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_child_hook_controls_and_parent_callbacks_follow_each_reused_start.expected
*/
// What it checks:
// 1. call_pre_post controls child pre_body independently for each start.
// 2. call_pre_post controls child post_body independently for each start.
// 3. Parent mid_do receives the exact child on each execution, including
//    optional-hook suppression and reuse.
// 4. Disabling optional child hooks does not suppress execution of its user
//    body.
// 5. Parent post_do receives the exact executed child for each selected
//    parent.
// 6. pre_start remains active when pre_body/post_body are disabled.
// 7. post_start remains active when pre_body/post_body are disabled.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.3.3 (UVM-CHILD-PRE-BODY-PER-START-CONTROL) gives rule 1
//    above. Setup: Run with zero, then reuse under another parent with one.
//    Expected: pre_body is skipped with zero and executes once across zero/one
//    reuse.
// 2. 1800.2-2020 14.2.3.8 (UVM-CHILD-POST-BODY-PER-START-CONTROL) gives rule 2
//    above. Setup: Run a child with zero and then one. Expected: post_body is
//    skipped for zero and invoked once for the enabled reuse.
// 3. 1800.2-2020 14.2.3.5 (UVM-CHILD-PARENT-MID-DO-EXACT-REUSED-CHILD) gives
//    rule 3 above. Setup: Execute one child under two independent parents.
//    Expected: Each selected parent has one mid_do callback with the original
//    child handle.
// 4. 1800.2-2020 14.2.3.6
//    (UVM-CHILD-BODY-DISPATCH-DURING-OPTIONAL-SUPPRESSION) gives rule 4 above.
//    Setup: Perform one disabled start and two reused starts. Expected: Body
//    counts match completed starts: one and two respectively.
// 5. 1800.2-2020 14.2.3.7 (UVM-CHILD-PARENT-POST-DO-EXACT-REUSED-CHILD) gives
//    rule 5 above. Setup: Suppress optional hooks, then reuse the child with
//    another parent. Expected: Each parent gets one post_do call with the same
//    child handle.
// 6. 1800.2-2020 14.2.3.2
//    (UVM-CHILD-PRE-START-PRESERVED-WITHOUT-OPTIONAL-HOOKS) gives rule 6
//    above. Setup: Compare a disabled start with zero/one reused starts.
//    Expected: pre_start counts one per completed start.
// 7. 1800.2-2020 14.2.3.9
//    (UVM-CHILD-POST-START-PRESERVED-WITHOUT-OPTIONAL-HOOKS) gives rule 7
//    above. Setup: Compare disabled and reenabled child executions. Expected:
//    post_start counts one per completed start.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_child_hook_controls_and_parent_callbacks_follow_each_reused_start;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class parent_sequence extends uvm_sequence#(uvm_sequence_item);
    int pre_calls = 0, mid_calls = 0, post_calls = 0;
    bit item_flag = 1, exact_mid = 1, exact_post = 1;
    uvm_sequence_item expected;
    function new(string name); super.new(name); endfunction
    task body(); endtask
    task pre_do(bit is_item); pre_calls++; item_flag = is_item; endtask
    function void mid_do(uvm_sequence_item this_item);
      mid_calls++; exact_mid &= this_item == expected;
    endfunction
    function void post_do(uvm_sequence_item this_item);
      post_calls++; exact_post &= this_item == expected;
    endfunction
  endclass
  class child_sequence extends uvm_sequence#(uvm_sequence_item);
    int pre_starts = 0, pre_bodies = 0, bodies = 0, post_bodies = 0, post_starts = 0;
    function new(string name); super.new(name); endfunction
    task pre_start(); pre_starts++; endtask
    task pre_body(); pre_bodies++; endtask
    task body(); #1; bodies++; endtask
    task post_body(); post_bodies++; endtask
    task post_start(); post_starts++; endtask
  endclass
  initial begin
    automatic parent_sequence first = new("first");
    automatic parent_sequence second = new("second");
    automatic child_sequence child = new("child");
    first.expected = child; second.expected = child;
    child.start(null, first, 25, 0); child.start(null, second, 25, 1);
    $display("UT: child_hooks %0d %0d %0d %0d %0d current_parent %0d", child.pre_starts,
             child.pre_bodies, child.bodies, child.post_bodies, child.post_starts,
             child.get_parent_sequence() == second);
    $display("UT: first_parent %0d %0d %0d exact %0d", first.pre_calls, first.mid_calls,
             first.post_calls, first.exact_mid && first.exact_post && !first.item_flag);
    $display("UT: second_parent %0d %0d %0d exact %0d", second.pre_calls, second.mid_calls,
             second.post_calls, second.exact_mid && second.exact_post && !second.item_flag);
    $finish;
  end
endmodule
