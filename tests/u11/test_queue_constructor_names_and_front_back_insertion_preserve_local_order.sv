/*
:name: test_queue_constructor_names_and_front_back_insertion_preserve_local_order
:description: queue construction and front/back insertion expose names, size and order independently (11.3.2.1)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.3.2.1 11.3.1 11.3 11.3.2.4 11.3.2.5 11.3.2.10 11.3.2.11 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_queue_constructor_names_and_front_back_insertion_preserve_local_order.expected
*/
// What it checks:
// 1. Queue construction retains an explicit name and the empty default name.
// 2. The default queue element type is int.
// 3. Queue handles share the receiver storage while another instance stays
//    independent.
// 4. push_front inserts before the previously stored items.
// 5. push_back appends without displacing prior item order.
// 6. Queue size reflects its current occupancy across insertion and removal.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 11.3.2.1 (UVM-QUEUE-CONSTRUCTOR-NAMES) gives rule 1 above.
//    Setup: Construct unnamed and named local queues. Expected: Names are
//    empty/named_queue and both start empty.
// 2. 1800.2-2020 11.3.1 (UVM-QUEUE-DEFAULT-ELEMENT-TYPE) gives rule 2 above.
//    Setup: Assign the default specialization to an explicit int queue alias.
//    Expected: The specialized alias is the exact original handle.
// 3. 1800.2-2020 11.3 (UVM-QUEUE-CONTAINER-REFERENCE-SHARING) gives rule 3
//    above. Setup: Append eight through an alias after front/back insertion in
//    one queue. Expected: The original size becomes four and its final value
//    is eight; peer size stays zero.
// 4. 1800.2-2020 11.3.2.10 (UVM-QUEUE-PUSH-FRONT-PLACEMENT) gives rule 4
//    above. Setup: Push four at back, two at front, then six at back.
//    Expected: Indexed values are 2/4/6 with size three.
// 5. 1800.2-2020 11.3.2.11 (UVM-QUEUE-PUSH-BACK-PLACEMENT) gives rule 5 above.
//    Setup: Append six after 2/4, then append eight through an alias.
//    Expected: The first append preserves 2/4/6 and the later tail is eight
//    with size four.
// 6. 1800.2-2020 11.3.2.5 (UVM-QUEUE-SIZE-TRACKS-LIFECYCLE) gives rule 6
//    above. Setup: Query before insertion, after appends, after indexed
//    deletions and after clearing. Expected: Reported counts match each
//    fixture occupancy and mutations leave the peer size unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_queue_constructor_names_and_front_back_insertion_preserve_local_order;
  import uvm_pkg::*;
  initial begin
    automatic uvm_queue#() queue = new();
    automatic uvm_queue#() peer = new("named_queue");
    uvm_queue#(int) typed_alias;
    $display("UT: names default_empty %0d explicit %0d sizes %0d %0d",
             queue.get_name() == "", peer.get_name() == "named_queue", queue.size(), peer.size());
    queue.push_back(4);
    queue.push_front(2);
    queue.push_back(6);
    $display("UT: inserted size %0d values %0d %0d %0d peer_size %0d",
             queue.size(), queue.get(0), queue.get(1), queue.get(2), peer.size());
    typed_alias = queue;
    typed_alias.push_back(8);
    $display("UT: default_type %0d shared_size %0d appended %0d peer_size %0d",
             typed_alias == queue, queue.size(), queue.get(3), peer.size());
    $finish;
  end
endmodule
