/*
:name: test_queue_nonempty_pop_ends_return_exact_handles_and_leave_the_middle
:description: nonempty queue pops preserve end handle identity and leave the intervening entry (11.3.2.8)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.3.2.8 11.3.2.9 11.3.2.4 11.3.2.5 11.3.2.10 11.3.2.11 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_queue_nonempty_pop_ends_return_exact_handles_and_leave_the_middle.expected
*/
module test_queue_nonempty_pop_ends_return_exact_handles_and_leave_the_middle;
  import uvm_pkg::*;
  class item extends uvm_object;
    int value;
    function new(string name, int number); super.new(name); value = number; endfunction
  endclass
  initial begin
    automatic uvm_queue#(item) queue = new("queue");
    automatic item front = new("front", 10);
    automatic item middle = new("middle", 20);
    automatic item back = new("back", 30);
    item found, popped_front, popped_back;
    queue.push_back(middle);
    queue.push_front(front);
    queue.push_back(back);
    found = queue.get(1);
    found.value = 25;
    $display("UT: get same %0d size %0d shared_value %0d",
             found == middle, queue.size(), middle.value);
    popped_front = queue.pop_front();
    popped_back = queue.pop_back();
    $display("UT: popped front %0d back %0d middle %0d size %0d",
             popped_front == front, popped_back == back, queue.get(0) == middle, queue.size());
    $finish;
  end
endmodule
