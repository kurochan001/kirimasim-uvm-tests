/*
:name: test_queue_delete_shifts_remaining_handles_and_default_delete_clears_only_one_instance
:description: indexed queue deletion shifts remaining entries and default deletion clears only the receiver (11.3.2.7)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.3.2.7 11.3.2.4 11.3.2.5 11.3.2.11 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_queue_delete_shifts_remaining_handles_and_default_delete_clears_only_one_instance.expected
*/
module test_queue_delete_shifts_remaining_handles_and_default_delete_clears_only_one_instance;
  import uvm_pkg::*;
  class item extends uvm_object;
    int value;
    function new(string name, int number); super.new(name); value = number; endfunction
  endclass
  initial begin
    automatic uvm_queue#(item) queue = new("queue");
    automatic uvm_queue#(item) peer = new("peer");
    automatic item first = new("first", 10);
    automatic item removed = new("removed", 20);
    automatic item third = new("third", 30);
    automatic item fourth = new("fourth", 40);
    queue.push_back(first);
    queue.push_back(removed);
    queue.push_back(third);
    queue.push_back(fourth);
    peer.push_back(removed);
    queue.delete(1);
    $display("UT: indexed size %0d order %0d peer %0d", queue.size(),
             queue.get(0) == first && queue.get(1) == third && queue.get(2) == fourth,
             peer.get(0) == removed && peer.size() == 1);
    queue.delete(0);
    queue.delete(queue.size() - 1);
    $display("UT: endpoints remaining %0d size %0d", queue.get(0) == third, queue.size());
    queue.delete();
    $display("UT: default_clear size %0d peer_size %0d peer_same %0d",
             queue.size(), peer.size(), peer.get(0) == removed);
    queue.push_back(first);
    queue.delete(-1);
    $display("UT: explicit_minus_one size %0d peer_size %0d", queue.size(), peer.size());
    $finish;
  end
endmodule
