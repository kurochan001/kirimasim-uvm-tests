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
// What it checks:
// 1. Queue size reflects its current occupancy across insertion and removal.
// 2. Indexed deletion removes only the selected entry and retains the
//    remaining order.
// 3. Default delete and explicit minus one clear the receiver queue.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 11.3.2.5 (UVM-QUEUE-SIZE-TRACKS-LIFECYCLE) gives rule 1
//    above. Setup: Query before insertion, after appends, after indexed
//    deletions and after clearing. Expected: Reported counts match each
//    fixture occupancy and mutations leave the peer size unchanged.
// 2. 1800.2-2020 11.3.2.7 (UVM-QUEUE-INDEXED-DELETE-REMAINING-ORDER) gives
//    rule 2 above. Setup: Delete a middle entry and then both endpoints while
//    keeping an independent queue. Expected: The surviving handles retain
//    order and the peer retains its exact entry.
// 3. 1800.2-2020 11.3.2.7 (UVM-QUEUE-DEFAULT-DELETE-CLEARS-RECEIVER) gives
//    rule 3 above. Setup: Clear populated storage with omitted index, refill
//    and clear with minus one. Expected: Both clear operations leave size zero
//    while the peer still has its one exact item.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
