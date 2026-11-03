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
