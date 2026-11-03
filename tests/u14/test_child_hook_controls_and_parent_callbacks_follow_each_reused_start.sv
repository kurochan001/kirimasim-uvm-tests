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
