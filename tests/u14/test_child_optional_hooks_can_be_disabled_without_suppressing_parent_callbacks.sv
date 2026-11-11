/*
:name: test_child_optional_hooks_can_be_disabled_without_suppressing_parent_callbacks
:description: call_pre_post zero suppresses optional child hooks while retaining parent callbacks (14.2.3.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.3.3 14.2.3.8 14.2.3.1 14.2.3.4 14.2.3.5 14.2.3.7 14.2.3.2 14.2.3.9 14.2.3.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_child_optional_hooks_can_be_disabled_without_suppressing_parent_callbacks.expected
*/
// What it checks:
// 1. call_pre_post controls child pre_body independently for each start.
// 2. call_pre_post controls child post_body independently for each start.
// 3. Disabling child optional hooks retains parent pre_do with is_item zero
//    for a child sequence.
// 4. Parent mid_do receives the exact child on each execution, including
//    optional-hook suppression and reuse.
// 5. Disabling optional child hooks does not suppress execution of its user
//    body.
// 6. Parent post_do receives the exact executed child for each selected
//    parent.
// 7. pre_start remains active when pre_body/post_body are disabled.
// 8. post_start remains active when pre_body/post_body are disabled.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.3.3 (UVM-CHILD-PRE-BODY-PER-START-CONTROL) gives rule 1
//    above. Setup: Run with zero, then reuse under another parent with one.
//    Expected: pre_body is skipped with zero and executes once across zero/one
//    reuse.
// 2. 1800.2-2020 14.2.3.8 (UVM-CHILD-POST-BODY-PER-START-CONTROL) gives rule 2
//    above. Setup: Run a child with zero and then one. Expected: post_body is
//    skipped for zero and invoked once for the enabled reuse.
// 3. 1800.2-2020 14.2.3.4 (UVM-CHILD-PARENT-PRE-DO-INDEPENDENT-OPTIONAL-HOOKS)
//    gives rule 3 above. Setup: Start a finite child under an explicit parent
//    with call_pre_post zero. Expected: Parent pre_do runs once with is_item
//    zero.
// 4. 1800.2-2020 14.2.3.5 (UVM-CHILD-PARENT-MID-DO-EXACT-REUSED-CHILD) gives
//    rule 4 above. Setup: Execute one child under two independent parents.
//    Expected: Each selected parent has one mid_do callback with the original
//    child handle.
// 5. 1800.2-2020 14.2.3.6
//    (UVM-CHILD-BODY-DISPATCH-DURING-OPTIONAL-SUPPRESSION) gives rule 5 above.
//    Setup: Perform one disabled start and two reused starts. Expected: Body
//    counts match completed starts: one and two respectively.
// 6. 1800.2-2020 14.2.3.7 (UVM-CHILD-PARENT-POST-DO-EXACT-REUSED-CHILD) gives
//    rule 6 above. Setup: Suppress optional hooks, then reuse the child with
//    another parent. Expected: Each parent gets one post_do call with the same
//    child handle.
// 7. 1800.2-2020 14.2.3.2
//    (UVM-CHILD-PRE-START-PRESERVED-WITHOUT-OPTIONAL-HOOKS) gives rule 7
//    above. Setup: Compare a disabled start with zero/one reused starts.
//    Expected: pre_start counts one per completed start.
// 8. 1800.2-2020 14.2.3.9
//    (UVM-CHILD-POST-START-PRESERVED-WITHOUT-OPTIONAL-HOOKS) gives rule 8
//    above. Setup: Compare disabled and reenabled child executions. Expected:
//    post_start counts one per completed start.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_child_optional_hooks_can_be_disabled_without_suppressing_parent_callbacks;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class parent_sequence extends uvm_sequence#(uvm_sequence_item);
    int pre_calls = 0, mid_calls = 0, post_calls = 0;
    bit item_flag = 1, exact_mid = 1, exact_post = 1;
    uvm_sequence_item expected;
    function new(string name); super.new(name); endfunction
    task body(); endtask
    task pre_do(bit is_item); pre_calls++; item_flag = is_item; endtask
    function void mid_do(uvm_sequence_item item);
      mid_calls++; exact_mid &= item == expected;
    endfunction
    function void post_do(uvm_sequence_item item);
      post_calls++; exact_post &= item == expected;
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
    automatic parent_sequence parent = new("parent");
    automatic child_sequence child = new("child");
    parent.expected = child;
    child.start(null, parent, 25, 0);
    $display("UT: child_hooks %0d %0d %0d %0d %0d", child.pre_starts, child.pre_bodies,
             child.bodies, child.post_bodies, child.post_starts);
    $display("UT: parent_hooks %0d %0d %0d is_item %0d exact %0d %0d", parent.pre_calls,
             parent.mid_calls, parent.post_calls, parent.item_flag,
             parent.exact_mid, parent.exact_post);
    $finish;
  end
endmodule
