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
// What it checks:
// 1. A valid queue get returns the stored handle without consuming the item.
// 2. A nonempty pop_front removes and returns the first stored handle.
// 3. A nonempty pop_back removes and returns the last stored handle.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 11.3.2.4 (UVM-QUEUE-VALID-GET-RETAINS-HANDLE) gives rule 1
//    above. Setup: Get the middle object from a three-entry queue and mutate
//    it. Expected: The exact middle handle is returned, size stays three and
//    its stored value changes to twenty-five.
// 2. 1800.2-2020 11.3.2.8 (UVM-QUEUE-NONEMPTY-POP-FRONT-HANDLE) gives rule 2
//    above. Setup: Pop front and then back from a three-handle queue.
//    Expected: The exact front handle is returned and only the middle remains
//    after both removals.
// 3. 1800.2-2020 11.3.2.9 (UVM-QUEUE-NONEMPTY-POP-BACK-HANDLE) gives rule 3
//    above. Setup: Pop back after the front was removed from a three-handle
//    queue. Expected: The exact back handle is returned and the remaining
//    middle handle has size one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
