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
